#!/usr/bin/env bash

# =========================================================================
# SCRIPT DE DEPLOY E ORQUESTRACÃO AUTOMATIZADA - POSTAL v3
# =========================================================================
# Este script lê as configurações do arquivo '.env', gera os arquivos de
# configuração, atualiza as senhas no YAML, inicializa o banco e cria
# o usuário administrador de forma 100% não interativa.
# =========================================================================

set -e

# Cores para logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # Sem Cor

echo -e "${GREEN}=== Iniciando Implantação Automatizada do Postal v3 ===${NC}"

# 1. Carregar variáveis de ambiente do arquivo .env
if [ ! -f .env ]; then
    echo -e "${RED}Erro: Arquivo '.env' não encontrado!${NC}"
    echo -e "Copie o arquivo '.env.example' para '.env' e configure suas variáveis antes de rodar."
    exit 1
fi

source .env

# Validar se as variáveis obrigatórias estão preenchidas
if [ -z "$POSTAL_DOMAIN" ] || [ -z "$DATABASE_ROOT_PASSWORD" ] || [ -z "$ADMIN_EMAIL" ] || [ -z "$ADMIN_PASSWORD" ]; then
    echo -e "${RED}Erro: Uma ou mais variáveis obrigatórias no '.env' estão vazias!${NC}"
    exit 1
fi

# 2. Criar pastas locais necessárias para volume
echo -e "\n${YELLOW}[1/6] Criando pastas de volume...${NC}"
mkdir -p config data/mariadb

# 3. Gerar arquivos de configuração via bootstrap (se não existirem)
if [ ! -f config/postal.yml ]; then
    echo -e "\n${YELLOW}[2/6] Executando Bootstrap para gerar configurações...${NC}"
    # Usamos um container temporário do próprio Postal para rodar o bootstrap e cuspir as configs na nossa pasta local /config
    docker run --rm \
      -v "$(pwd)/config:/config" \
      ghcr.io/postalserver/postal:3.3.7 \
      postal bootstrap "$POSTAL_DOMAIN"
    echo -e "${GREEN}Configurações base geradas com sucesso em config/${NC}"
else
    echo -e "\n${YELLOW}[2/6] Configurações em config/postal.yml já existem. Pulando bootstrap.${NC}"
fi

# 4. Atualizar senhas e escuta no postal.yml usando Python (sem nano manual)
echo -e "\n${YELLOW}[3/6] Atualizando configurações no postal.yml...${NC}"
python3 -c "
import re

with open('config/postal.yml', 'r') as f:
    content = f.read()

# Substituir a senha padrão 'postal' pela senha do .env
content = content.replace('password: postal', 'password: \"$DATABASE_ROOT_PASSWORD\"')

# Garantir que a escuta seja pública (0.0.0.0) para conexão do proxy docker
if 'web_server' not in content:
    content += '\nweb_server:\n  default_bind_address: 0.0.0.0\n'

with open('config/postal.yml', 'w') as f:
    f.write(content)
"
echo -e "${GREEN}Configurações do postal.yml atualizadas com as senhas do .env!${NC}"

# 5. Subir o Banco de Dados MariaDB e aguardar inicialização
echo -e "\n${YELLOW}[4/6] Iniciando o banco de dados MariaDB...${NC}"
docker compose up -d database

echo -e "Aguardando 10 segundos para o MariaDB iniciar completamente..."
sleep 10

# 6. Inicializar as tabelas do Banco de Dados
echo -e "\n${YELLOW}[5/6] Inicializando banco de dados (tabelas e migrações)...${NC}"
docker compose run --rm web postal initialize

# 7. Criar o Usuário Administrador de forma automática (não interativa)
echo -e "\n${YELLOW}[6/6] Criando usuário administrador master no painel...${NC}"
# Usamos o Rails Runner para criar o usuário direto no banco, evitando o prompt do 'make-user'
docker compose run --rm web postal runner "
if User.where(email: '$ADMIN_EMAIL').exists?
  puts 'Usuário $ADMIN_EMAIL já existe no banco. Pulando criação.'
else
  User.create!(
    email: '$ADMIN_EMAIL',
    first_name: 'CDC',
    last_name: 'Envios',
    password: '$ADMIN_PASSWORD',
    admin: true
  )
  puts 'Usuário administrador criado com sucesso!'
end
"

# 8. Iniciar todos os containers em produção
echo -e "\n${GREEN}=== Inicializando todos os serviços do Postal v3 ===${NC}"
docker compose up -d

echo -e "\n${GREEN}================================================================${NC}"
echo -e " IMPLANTAÇÃO CONCLUÍDA COM SUCESSO!"
echo -e " Acesso Web: ${YELLOW}https://${POSTAL_DOMAIN}${NC} (via Nginx/Easypanel)"
echo -e " Usuário: ${YELLOW}${ADMIN_EMAIL}${NC}"
echo -e "================================================================"
