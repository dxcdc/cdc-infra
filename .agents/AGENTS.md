# REGRAS DE ARQUITETURA DO PROJETO (CDC-INFRA)
Bem-vindo(a) à nova sessão! Se você é um agente de Inteligência Artificial assumindo este projeto, é vital que você obedeça rigorosamente a este perfil de infraestrutura para dar continuidade ao excelente trabalho que fizemos:

## 1. Contexto do Hardware
Este repositório roda em uma VPS monstruosa (KVM 8, 8 vCPUs, 32GB RAM, 400GB NVMe, Ubuntu/Debian). Recursos de memória não são um problema aqui.

## 2. Padrões de Imagem Docker (DevOps Rigoroso)
- **NUNCA UTILIZE A TAG `:latest`**. Em todos os arquivos `docker-compose.yml`, você deve pesquisar e travar (Pin) a versão da imagem oficial em sua numeração estável mais recente (Ex: `wg-easy:14`). Jamais aceite sugestões de deixar a versão livre.
- **Nosso Docker Hub Oficial:** O nome de usuário para este catálogo na nuvem é `gttransformadigital`. Se você for instruído a fazer *build* e *push* de uma nova imagem customizada, sempre use o prefixo `gttransformadigital/nome-da-imagem`.

## 3. Padrões de Serviço do Catálogo
Todo serviço criado neste repositório DEVE OBRIGATORIAMENTE conter:
- Um `docker-compose.yml` claro e bem orquestrado.
- Um arquivo `.env` base (sem senhas de produção explícitas, mas com as variáveis de exemplo).
- Um arquivo `ajuda.txt` detalhado em português, focando muito em alertas de Portas bloqueadas na VPS e em processos de inicialização difíceis.
- Não altere as pastas já estruturadas como Moodle, ERPNext, Postal e VPN, a menos que o usuário solicite explicitamente uma nova funcionalidade.

## 4. Filosofia de Trabalho
O usuário já sabe trabalhar com Docker. Não perca tempo explicando comandos básicos como `docker-compose up`. Foque em engenharia de ponta, segurança, microserviços e roteamento nativo. Leia o `CONTEXTO_ONG.md` para entender as maravilhas técnicas que já implementamos!
