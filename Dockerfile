FROM php:7.4-apache

# Paquetes del sistema necesarios para OpenCATS y extensiones PHP
RUN apt-get update && apt-get install -y \
    git unzip curl antiword poppler-utils html2text unrtf \
    libxml2-dev libjpeg-dev libpng-dev libfreetype6-dev libzip-dev \
  && rm -rf /var/lib/apt/lists/*

# Extensiones PHP requeridas
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" gd mysqli zip \
 && docker-php-ext-install soap || true

# Apache: rewrite/headers y permitir .htaccess
RUN a2enmod rewrite headers \
 && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

WORKDIR /var/www/html

# Variables para elegir repo/ref si quieres cambiarlas desde build-args
ARG OPENCATS_REPO=https://github.com/opencats/OpenCATS.git
ARG OPENCATS_REF=master

# Descargar OpenCATS y dejarlo en /var/www/html (sin usar rsync)
RUN rm -rf /var/www/html/* \
 && git clone --depth 1 --branch "${OPENCATS_REF}" "${OPENCATS_REPO}" /tmp/opencats \
 && cp -a /tmp/opencats/. /var/www/html/ \
 && rm -rf /tmp/opencats/.git \
 && chown -R www-data:www-data /var/www/html

# Ajustes PHP recomendados
RUN { \
  echo "upload_max_filesize=20M"; \
  echo "post_max_size=25M"; \
  echo "memory_limit=512M"; \
  echo "max_execution_time=120"; \
} > /usr/local/etc/php/conf.d/opencats.ini

EXPOSE 80
