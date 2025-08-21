FROM php:7.4-apache

RUN apt-get update && apt-get install -y \
    git unzip curl libzip-dev libpng-dev libonig-dev libxml2-dev \
 && docker-php-ext-install mysqli pdo pdo_mysql gd mbstring xml zip \
 && a2enmod rewrite

RUN printf "<Directory /var/www/html>\nAllowOverride All\n</Directory>\n" > /etc/apache2/conf-available/opencats.conf \
 && a2enconf opencats

WORKDIR /var/www/html
RUN git clone --depth 1 https://github.com/opencats/OpenCATS.git . \
 && chown -R www-data:www-data /var/www/html

RUN printf "upload_max_filesize=25M\npost_max_size=25M\nmemory_limit=512M\n" > /usr/local/etc/php/conf.d/uploads.ini

HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=10 \
  CMD curl -fsS http://127.0.0.1/ || exit 1
