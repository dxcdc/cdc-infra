#!/bin/bash
# =========================================================================
# SCRIPT MAGICO DE INICIALIZACAO DO POSTAL
# Como o Postal exige arquivos de configuracao antes de subir, este script
# automatiza toda a dor de cabeca de geracao de chaves.
# =========================================================================

source .env

echo "1. Criando a pasta de configuracoes local..."
mkdir -p config

if [ ! -f config/postal.yml ]; then
    echo "2. Gerando arquivo postal.yml e signing.key atraves do bootstrap..."
    # Rodamos o comando bootstrap usando um container temporario
    docker run --rm -v $(pwd)/config:/config ghcr.io/postalserver/postal:latest postal bootstrap $POSTAL_DOMAIN
    
    echo "-------------------------------------------------------------------------"
    echo "ATENÇÃO: O arquivo config/postal.yml foi gerado!"
    echo "Antes de prosseguir, edite esse arquivo e altere as senhas do mariadb e do rabbitmq"
    echo "para que fiquem exatamente iguais as que estao no seu arquivo .env"
    echo "Também altere o dns_mx_records para mx.postal.cdc.org.br (ou o seu dominio real)"
    echo "Apos editar, rode esse script novamente!"
    echo "-------------------------------------------------------------------------"
    exit 0
fi

echo "3. Subindo o banco MariaDB e RabbitMQ temporariamente para criar as tabelas..."
docker compose up -d mariadb rabbitmq
echo "Aguardando 15 segundos para os bancos de dados acordarem..."
sleep 15

echo "4. Inicializando a estrutura de tabelas do Postal no Banco..."
docker run --rm -i -t -v $(pwd)/config:/config --network postal_default ghcr.io/postalserver/postal:latest postal initialize

echo "5. Criando seu usuario administrador..."
docker run --rm -i -t -v $(pwd)/config:/config --network postal_default ghcr.io/postalserver/postal:latest postal make-user

echo "================================================="
echo "SUCESSO! O TERRENO ESTÁ PREPARADO!"
echo "Agora voce ja pode rodar: docker compose up -d"
echo "E acessar a interface do Postal na porta 5000!"
echo "================================================="
