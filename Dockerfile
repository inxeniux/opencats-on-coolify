# Dockerfile
FROM php:7.4-apache

# Paquetes del sistema necesarios por OpenCATS y extensiones PHP
RUN apt-get update && apt-get install -y \
    git unzip curl \
    antiword poppler-utils html2text unrtf \
    libxml2-dev \
 && rm -rf /var/lib/apt/lists/*

# Extensiones PHP requeridas
RUN docker-php-ext-install mysqli \
 && docker-php-ext-install soap || true

# Habilitar módulos de Apache necesarios
RUN a2enmod rewrite headers \
 && sed -ri 's/AllowOverride\s+None/AllowOverride All/i' /etc/apache2/apache2.conf

# Variables con defaults (puedes sobreescribirlas vía .env o compose)
ARG OPENCATS_REPO=https://github.com/opencats/OpenCATS.git
ARG OPENCATS_REF=master

WORKDIR /var/www/html

# Descargar OpenCATS y copiar incluyendo archivos ocultos (.htaccess, etc.)
RUN rm -rf /var/www/html/* \
 && git clone --depth 1 --branch ${OPENCATS_REF} ${OPENCATS_REPO} /tmp/opencats \
 && cp -a /tmp/opencats/. /var/www/html/ \
 && rm -rf /tmp/opencats/.git \
 && chown -R www-data:www-data /var/www/html
