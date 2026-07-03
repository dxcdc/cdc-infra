FROM php:8.3-apache
LABEL maintainer="CDC"
LABEL service="moodle"
LABEL built_for="Producao"

# 1. Instalar bibliotecas essenciais do sistema operacional e Composer
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    mariadb-client \
    git \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer globalmente
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# 2. Instalar e configurar extensões do PHP obrigatórias para o Moodle (incluindo exif)
RUN docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install gd intl mysqli zip soap opcache exif

# 3. Baixar o código-fonte oficial do Moodle 5.0, o tema cdc_moodle e instalar dependências do Composer
RUN rm -rf /var/www/html/* \
    && git clone --depth 1 --branch MOODLE_502_STABLE https://github.com/moodle/moodle.git /var/www/html \
    && git clone --depth 1 https://github.com/dxcdc/temamoodle.git /var/www/html/theme/cdc_moodle \
    && git clone --depth 1 --branch MOODLE_502_STABLE https://github.com/markn86/moodle-mod_customcert.git /var/www/html/mod/customcert \
    && cd /var/www/html \
    && composer install --no-dev --classmap-authoritative

# Criar um arquivo config.php dinâmico baseado em variáveis de ambiente
RUN echo '<?php \n\
unset($CFG); \n\
global $CFG; \n\
$CFG = new stdClass(); \n\
$CFG->dbtype    = "mariadb"; \n\
$CFG->dblibrary = "native"; \n\
$CFG->dbhost    = getenv("MOODLE_DB_HOST") ?: "moodle-db"; \n\
$CFG->dbname    = getenv("MOODLE_DB_NAME") ?: "moodle_db"; \n\
$CFG->dbuser    = getenv("MOODLE_DB_USER") ?: "mariadb"; \n\
$CFG->dbpass    = getenv("MOODLE_DB_PASS") ?: ""; \n\
$CFG->prefix    = "mdl_"; \n\
$CFG->dboptions = array ( \n\
  "dbpersist" => 0, \n\
  "dbport" => 3306, \n\
  "dbsocket" => "", \n\
  "dbcollation" => "utf8mb4_unicode_ci", \n\
); \n\
$CFG->wwwroot   = getenv("MOODLE_WWWROOT") ?: "https://educa.cdc.org.br"; \n\
$CFG->dataroot  = "/var/www/moodledata"; \n\
$CFG->admin     = "admin"; \n\
$CFG->directorypermissions = 0777; \n\
$CFG->sslproxy  = true; \n\
$CFG->theme     = "cdc_moodle"; \n\
require_once(__DIR__ . "/lib/setup.php");' > /var/www/html/config.php

RUN chown -R www-data:www-data /var/www/html

# 4. Criar a pasta de arquivos sensíveis (moodledata) e dar permissão total
RUN mkdir -p /var/www/moodledata \
    && chown -R www-data:www-data /var/www/moodledata \
    && chmod -R 777 /var/www/moodledata

# 5. Ajustar configurações recomendadas do PHP para o Moodle não travar
RUN echo "max_input_vars = 5000" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "memory_limit = \${PHP_MEMORY_LIMIT:-512M}" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/moodle.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/moodle.ini

# 6. Atualizar o Apache para apontar para a nova pasta /public do Moodle 5 e expor variáveis de ambiente
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# Expor variáveis do Docker para o PHP no Apache
RUN echo "PassEnv MOODLE_DB_HOST MOODLE_DB_NAME MOODLE_DB_USER MOODLE_DB_PASS MOODLE_WWWROOT PHP_MEMORY_LIMIT" > /etc/apache2/conf-available/expose-env.conf \
    && a2enconf expose-env

EXPOSE 80
CMD ["apache2-foreground"]
