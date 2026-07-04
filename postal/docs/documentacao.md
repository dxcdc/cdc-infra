# Documentação Geral - Servidor de Disparo de E-mails Postal (CDC)

Este documento funciona como o **Índice Central** e o **Manual Geral** de toda a arquitetura de e-mails da CDC. Ele reúne a descrição do ecossistema, os detalhes do sistema de automação e as principais lições aprendidas durante o processo de design e implantação.

---

## 📚 Índice de Documentos de Suporte

Para acessar manuais específicos e runbooks de console, consulte os arquivos abaixo:

*   **[Manual de Arquitetura de Rede e Infraestrutura](file:///home/vier/Documentos/Code/cdc-infra/postal/docs/ajuda_infra.md)**: Desenho esquemático de rede, caminhos físicos e comandos básicos do Postal.
*   **[Guia de Resolução de Problemas (Troubleshooting)](file:///home/vier/Documentos/Code/cdc-infra/postal/docs/troubleshooting.md)**: Soluções passo a passo para falhas comuns (Timeouts, SMTP bloqueado, e-mails caindo em SPAM).
*   **[Post-Mortem de Implantação](file:///home/vier/Documentos/Code/cdc-infra/postal/docs/postmortem.md)**: Análise detalhada dos incidentes encontrados durante a configuração e suas resoluções.
*   **[Runbook - Histórico de Comandos do Terminal](file:///home/vier/Documentos/Code/cdc-infra/postal/docs/historico_comandos.md)**: Registro limpo de todos os comandos de console rodados na VPS com dados sensíveis mascarados.

---

## 🛠️ O Sistema de Automação (deploy.sh)

A implantação do Postal v3 foi automatizada em sua totalidade no script **[deploy.sh](file:///home/vier/Documentos/Code/cdc-infra/postal/deploy.sh)**. Ele foi desenvolvido sob a filosofia de infraestrutura como código (IaC), permitindo que a aplicação seja iniciada em qualquer VPS Ubuntu sem necessidade de inputs interativos.

### Como a automação funciona:
1.  **Carregamento de Variáveis:** Lê e valida o arquivo local `.env` (baseado no template [.env.example](file:///home/vier/Documentos/Code/cdc-infra/postal/.env.example)).
2.  **Bootstrap Isolado em Docker:** Executa o bootstrap do Postal dentro de um container temporário da imagem oficial, gerando os arquivos de configuração na pasta local `./config` do projeto de forma limpa.
3.  **Configuração Programática do YAML:** Usa o interpretador Python padrão do Ubuntu para abrir `/config/postal.yml`, atualizar a senha do banco de dados e inserir o bind address público (`0.0.0.0`) para que a aplicação aceite conexões externas originadas de containers Docker.
4.  **Orquestração de Banco e Tabelas:** Inicializa o container MariaDB e executa o `postal initialize` para carregar o esquema do banco de dados.
5.  **Provisionamento Não Interativo do Admin:** Bypassa o prompt interativo do comando `postal make-user` executando diretamente no interpretador do Ruby on Rails (`postal runner`) a criação do usuário administrador a partir das variáveis do `.env`.
6.  **Inicialização de Produção:** Sobe todos os serviços integrados (web, smtp e worker) sob o nome de projeto do Docker `postal`.

---

## 💡 Lições Aprendidas (Maturidade em DevOps)

A implantação bem-sucedida do Postal na VPS da CDC nos trouxe lições cruciais sobre redes Docker, controle de portas e desenvolvimento de scripts estáveis:

### 1. Simplificação Arquitetural do Postal v3 vs. v2
*   **Aprendizado:** A versão 3 do Postal removeu o RabbitMQ e processos secundários de fila, simplificando a orquestração do Docker Compose. A aplicação agora roda sob `network_mode: host` por padrão. Isso reduz drasticamente o consumo de memória RAM na VPS da CDC, tornando viável a hospedagem compartilhada com o Moodle e outros serviços.

### 2. Comportamento de Redes Customizadas do Docker (Easypanel)
*   **Aprendizado:** O Easypanel isola seus aplicativos em subredes privadas (no nosso caso, a faixa `10.11.0.x`). Quando o proxy Nginx tenta passar a requisição para o host via IP tradicional do Docker (`172.17.0.1`), a conexão falha.
*   **Regra de Ouro:** Devemos sempre identificar a faixa de rede do container cliente para apontar para o gateway correto (neste caso, `10.11.0.1`), e garantir que o serviço no host (`postal-web`) esteja escutando em todas as interfaces (`0.0.0.0`) em vez de se limitar a `127.0.0.1`.

### 3. Escape de Caracteres Especiais no Console (Zsh/Bash)
*   **Aprendizado:** A presença do caractere de exclamação (`!`) em senhas enviadas em comandos diretos do terminal faz o interpretador Zsh falhar devido à expansão de histórico do shell (com o erro `no such event`).
*   **Regra de Ouro:** Senhas ou textos com caracteres especiais em shell scripts ou comandos de terminal devem obrigatoriamente estar envolvidos em aspas simples (`'...'`) para inibir a interpretação do shell.

### 4. Provisionamento Silencioso (Silent Seeding) em Rails
*   **Aprendizado:** Muitos softwares de código aberto possuem interfaces de terminal interativas. Ao criar scripts de automação, usar os interpretadores nativos da linguagem da aplicação (como `rails runner` ou `postal runner`) para executar comandos Ruby diretamente no contexto do banco de dados elimina o bloqueio de prompts, permitindo automações robustas em pipelines de CI/CD.
