FROM php:7.4-apache

# Paquetes y extensiones PHP necesarias
RUN apt-get update && apt-get install -y \
    git unzip wget ca-certificates \
    libpng-dev libjpeg-dev libfreetype6-dev libzip-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) gd mysqli pdo pdo_mysql zip \
 && a2enmod rewrite headers expires \
 && rm -rf /var/lib/apt/lists/*

# Clonar OpenCATS (código de la app) dentro del DocumentRoot
RUN git clone --depth 1 https://github.com/opencats/OpenCATS.git /var/www/html \
 && chown -R www-data:www-data /var/www/html

# Permitir .htaccess y rewrites en /var/www/html
RUN printf '<Directory "/var/www/html">\nAllowOverride All\nRequire all granted\n</Directory>\n' > /etc/apache2/conf-available/opencats.conf \
 && a2enconf opencats

# Healthcheck simple
RUN echo "<?php http_response_code(200); echo 'OK';" > /var/www/html/health.php
