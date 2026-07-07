# CONTEXTO HISTÓRICO DA INFRAESTRUTURA (ONG CDC)
Este documento resume os feitos de engenharia complexa alcançados para orquestrar os sistemas vitais da ONG. Se você está lendo isso, saiba que não lidamos com infraestruturas superficiais.

## 1. Moodle 5.0 (Custom Build Extremo)
A imagem que usamos do Moodle **não é oficial**. Nós mesmos construímos o Dockerfile (`gttransformadigital/moodle:5.0`).
- **Desafios Vencidos:** Injetamos a força o PHP 8.3 na imagem base, instalamos o `Composer`, clonamos o repositório Github com o tema customizado `cdc_moodle` (baseado no tema Uena) e injetamos o plugin `customcert`.
- **Mudança Arquitetural da v5.0:** Lembre-se que o Moodle 5.x usa obrigatoriamente a sub-pasta `/public` como DocumentRoot (Webroot) por segurança. Nosso Apache já foi reprogramado via Dockerfile para apontar para essa pasta, redirecionando perfeitamente a leitura do arquivo `config.php` dinâmico construído via Variáveis de Ambiente.
- A imagem `gttransformadigital/moodle:5.0` já está hospedada no Docker Hub.

## 2. Orquestração do ERPNext (Frappe)
Para rodar o ERPNext (pasta `erpnext`), montamos uma teia de 10 microserviços.
- Rodamos o MariaDB customizado e Três Redises em paralelo (Cache, Fila e Websockets).
- Injetamos um container-robô efêmero chamado `create-site` que fica escutando a rede. Quando o MariaDB acorda, esse robô compila as tabelas em Python, configura a senha inicial e comete "autodestruição", evitando que o técnico precise abrir o painel bash para rodar comandos `bench`.

## 3. Motor SMTP de Alta Volumetria (Postal)
Criamos a pasta `postal` para despachar milhares de e-mails do Moodle e ERPNext e fugir do SPAM.
- **Desafio do Boot:** O Postal só funciona se possuir arquivos de configuração com chaves criptográficas atreladas a um domínio. Resolvemos isso criando um bash script chamado `instalar_postal.sh`. Quando executado, ele usa containers Docker passageiros para fabricar o `postal.yml` base, liga o RabbitMQ, compila o Banco, pede ao usuário na tela preta os dados do novo Admin e pronto.
- A **Porta 25 UDP** precisa de intervenção manual no suporte da nuvem do usuário para ser liberada.

## 4. VPN Corporativa Invisível (WireGuard / WG-Easy)
A pasta `vpn` contém a arma secreta para esconder portas dos servidores na internet.
- Subimos o WG-Easy (fixado cautelosamente na versão 14).
- A genialidade está no `docker-compose.yml`, onde repassamos as flags `NET_ADMIN`, `SYS_MODULE` e `ip_forward=1` direto para o kernel do Linux hospedeiro. Isso permite o roteamento nativo perfeito de pacotes por dentro do túnel criptografado pela **porta UDP 51820**.

*Fim do Relatório. Com essa base de conhecimento, você tem os poderes técnicos necessários para iniciar a nova fase da empresa!*
