FROM php:7.4-apache

ARG OPENCATS_REPO=https://github.com/opencats/OpenCATS.git
ARG OPENCATS_REF=master

# Paquetes necesarios (incluye rsync)
RUN apt-get update && apt-get install -y \
    git unzip curl rsync \
    antiword poppler-utils html2text unrtf \
    libxml2-dev \
 && rm -rf /var/lib/apt/lists/*

# Extensiones PHP requeridas por OpenCATS
RUN docker-php-ext-install mysqli \
 && docker-php-ext-install soap || true

# Activar módulos de Apache
RUN a2enmod rewrite headers

WORKDIR /var/www/html

# Descargar OpenCATS
RUN rm -rf /var/www/html/* \
 && git clone --depth 1 --branch ${OPENCATS_REF} ${OPENCATS_REPO} /tmp/opencats \
 && rsync -a /tmp/opencats/ /var/www/html/ \
 && rm -rf /tmp/opencats/.git

# Permisos
RUN chown -R www-data:www-data /var/www/html \
 && find /var/www/html -type d -exec chmod 755 {} \; \
 && find /var/www/html -type f -exec chmod 644 {} \;

EXPOSE 80
