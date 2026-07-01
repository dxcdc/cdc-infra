# Guia de Infraestrutura do Moodle 5.0 (Edição Customizada CDC)

Este documento descreve a infraestrutura técnica, os requisitos, o guia de instalação automatizada e as políticas de backup para a plataforma Moodle 5.0 com o tema **CDC Moodle** em ambiente de produção (Docker/Easypanel).

---

## 1. Visão Geral e Propósito
O Moodle é o Sistema de Gestão da Aprendizagem (LMS) mais utilizado no mundo. Esta versão foi construída sob medida para o **Centro de Desenvolvimento e Cidadania (CDC)** usando PHP 8.3 oficial, compilando nativamente as dependências essenciais (`gd`, `intl`, `zip`, `exif`) para garantir segurança, desempenho e estabilidade de longo prazo.

---

## 2. Anatomia Técnica
* **Servidor Web:** Apache (nativamente na porta 80).
* **Diretório Público:** Por questões de segurança do Moodle 5.x, o Apache aponta exclusivamente para a pasta `/var/www/html/public`. Isso isola e protege o arquivo vital `config.php` de acessos diretos externos.
* **Banco de Dados:** MariaDB 11+ rodando em contêiner separado na mesma rede interna do Docker.

---

## 3. Instalação e Configuração (Suporte a Variáveis de Ambiente)
Diferente das instalações padrão, esta imagem customizada foi reestruturada para suportar configuração automática via variáveis de ambiente no Docker/Easypanel. Ela gera o arquivo `config.php` dinamicamente no boot do Apache.

Configure as seguintes variáveis na aba **Environment (Ambiente)** do Easypanel para o App Moodle:
* `MOODLE_DB_HOST`: Host interno do banco de dados (padrão: `moodle-db`).
* `MOODLE_DB_NAME`: Nome do banco de dados SQL (padrão: `moodle_db`).
* `MOODLE_DB_USER`: Usuário do banco de dados (padrão: `mariadb`).
* `MOODLE_DB_PASS`: Senha do banco (deve ser a mesma gerada pelo Easypanel no MariaDB).
* `MOODLE_WWWROOT`: URL completa com protocolo (ex: `https://educa.cdc.org.br`).
* `PHP_MEMORY_LIMIT`: Limite de alocação de memória do PHP (padrão recomendado: `512M`).

---

## 4. Guia de Volumes e Backups (CRÍTICO)
* **Persistência de Dados:** **APENAS** o diretório `/var/www/moodledata` (onde ficam os arquivos carregados por professores e alunos, logs e sessões) deve ser montado como volume persistente.
* **NÃO persista a pasta `/var/www/html`:** Persistir esta pasta sobrescreve os novos deploys do Dockerfile (incluindo o Composer, o tema customizado e o config.php dinâmico). Deixe o código-fonte rodar diretamente da imagem compilada.
* **Backup:** Faça backup diário do volume do `/var/www/moodledata` e do volume de dados do MariaDB. Force o acesso via HTTPS pelo Proxy Reverso (Traefik/Nginx) habilitando o SSL.

---

## 5. Possíveis Impeditivos ao Subir / Atualizar (Atenção ao Dockerfile)
Como este Moodle é compilado do zero, existem fatores externos que podem quebrar o comando `docker build`:
1. **Mudança de Branch no GitHub:** O Dockerfile clona a branch `MOODLE_502_STABLE`. Se a Moodle HQ lançar novas versões e remover branches antigas, o build falhará. Sempre mantenha o número da branch atualizado.
2. **Atualizações do PHP:** O Moodle 5 exige PHP 8.3+. Se a imagem base `php:8.3-apache` for alterada no futuro, novas bibliotecas do Linux (no `apt-get`) podem ser exigidas.

---

## 6. Troubleshooting Rápido
* **Erro 'rootdirpublic' ou 'Forbidden':** O Moodle 5 exige que a pasta web seja a `/public`. O nosso Dockerfile já faz essa injeção no Apache, mas se você tentar acessar e der erro, verifique se não há contêineres antigos rodando na mesma porta.
* **Erro de Conexão com o Banco (using password: NO):** Verifique se a variável de ambiente `MOODLE_DB_PASS` foi salva corretamente na aba *Environment* do App do Moodle no Easypanel (e não no MariaDB) e se você clicou em **Deploy** após salvar.
* **Tela Branca de Permissão:** Verifique se as permissões da pasta `/var/www/moodledata` estão aplicadas como `www-data` no Dockerfile. O Moodle se recusa a iniciar se não tiver acesso de gravação.
