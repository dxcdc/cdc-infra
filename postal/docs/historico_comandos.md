# Histórico de Comandos Utilizados na Implantação

Este documento serve como um **Runbook (Livro de Receitas)** com o histórico passo a passo de todos os comandos que executamos no terminal da VPS para subir o Postal. 

Todos os dados sensíveis (IPs, senhas e domínios reais) foram substituídos por placeholders indicados entre `< >`.

---

## 1. Preparação da VPS e Dependências

```bash
# Atualizar repositórios e instalar utilitários base
sudo apt-get update
sudo apt-get install -y git curl jq gnupg lsb-release

# Clonar o repositório oficial do instalador do Postal
sudo mkdir -p /opt/postal
sudo git clone https://github.com/postalserver/install.git /opt/postal/install

# Criar link simbólico para tornar o comando 'postal' global
sudo ln -sf /opt/postal/install/bin/postal /usr/bin/postal
```

---

## 2. Configuração Inicial (Bootstrap)

```bash
# Executar o bootstrap do domínio (gera a pasta /opt/postal/config/)
sudo postal bootstrap <DOMINIO_DO_POSTAL>
```

---

## 3. Banco de Dados MariaDB (Container Standalone)

```bash
# Subir o MariaDB no Docker escutando apenas localmente na porta 3306
# Nota: Lembre-se de envolver a senha com aspas simples caso contenha caracteres especiais como !
docker run -d \
  --name postal-mariadb \
  -p 127.0.0.1:3306:3306 \
  --restart always \
  -e MARIADB_DATABASE=postal \
  -e MARIADB_ROOT_PASSWORD='<SENHA_DO_BANCO>' \
  mariadb
```

---

## 4. Edição de Arquivos de Configuração

```bash
# Ajustar o arquivo postal.yml para cadastrar a senha do banco e a escuta em 0.0.0.0
sudo nano /opt/postal/config/postal.yml
```

---

## 5. Inicialização da Aplicação e Contas

```bash
# Criar as tabelas no banco de dados
sudo postal initialize

# Criar o usuário administrador no painel
sudo postal make-user
```

---

## 6. Inicialização do Docker Stack do Postal

```bash
# Parar containers (caso tivessem subido com o namespace incorreto da pasta)
cd /opt/postal/install && sudo docker compose down

# Subir a aplicação na rede com o namespace correto 'postal'
sudo docker compose -p postal up -d

# Validar se os serviços estão ativos e rodando
sudo postal status
```

---

## 7. Diagnóstico de Portas e Firewall

```bash
# Verificar em qual porta e IP o Postal Web está escutando na VPS
sudo ss -tulpn | grep 5000

# Verificar se o firewall do Ubuntu (UFW) está ativo
sudo ufw status

# Permitir a porta SMTP interna no firewall caso necessário
sudo ufw allow 2525/tcp
```

---

## 8. Configuração do Proxy Reverso Nginx (No Easypanel)

```bash
# Escrever a rota do Proxy Nginx apontando para o IP de gateway do Easypanel
# Nota: Garanta o uso de 'EOF' com aspas simples para não expandir variáveis do Nginx no terminal local
cat << 'EOF' > /etc/easypanel/projects/<NOME_DO_PROJETO>/postal-proxy/volumes/config/default.conf
server {
    listen 80;
    server_name <DOMINIO_DO_POSTAL>;

    location / {
        proxy_pass http://10.11.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF
```
