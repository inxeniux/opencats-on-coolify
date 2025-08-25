# Etapa para obtener composer
FROM composer:2 AS composer

# Imagen de PHP
FROM php:7.4-apache

ENV COMPOSER_ALLOW_SUPERUSER=1 \
    APACHE_DOCUMENT_ROOT=/var/www/html

# Paquetes del sistema y extensiones PHP requeridas por OpenCATS
RUN apt-get update && apt-get install -y \
      git unzip rsync curl \
      antiword poppler-utils html2text unrtf \
      libxml2-dev libzip-dev libicu-dev \
  && docker-php-ext-install mysqli soap zip intl \
  && a2enmod rewrite headers \
  && echo '<Directory /var/www/html/>\nAllowOverride All\nRequire all granted\n</Directory>' > /etc/apache2/conf-available/opencats.conf \
  && a2enconf opencats \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Traer el código de OpenCATS
RUN rm -rf /var/www/html/* \
  && git clone --depth 1 --branch master https://github.com/opencats/OpenCATS.git /tmp/opencats \
  && rsync -a /tmp/opencats/ /var/www/html/ \
  && rm -rf /tmp/opencats/.git

# Instalar dependencias de Composer (crea ./vendor/autoload.php)
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress

# Permisos y healthcheck
RUN chown -R www-data:www-data /var/www/html \
  && find /var/www/html -type d -exec chmod 755 {} \; \
  && find /var/www/html -type f -exec chmod 644 {} \;

HEALTHCHECK CMD curl -fsS http://127.0.0.1/ || exit 1
