# Imagen con Apache + PHP 7.4 (compat con OpenCATS)
FROM php:7.4-apache

# Paquetes y extensiones PHP necesarias
RUN a2enmod rewrite headers expires \
 && apt-get update && apt-get install -y --no-install-recommends \
      git unzip libpng-dev libjpeg62-turbo-dev libfreetype6-dev libzip-dev \
      libxml2-dev libicu-dev default-mysql-client \
 && docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j"$(nproc)" gd mysqli pdo pdo_mysql zip intl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Traemos el código de OpenCATS
RUN git clone --depth 1 https://github.com/opencats/OpenCATS.git /tmp/opencats \
 && rm -rf /var/www/html/* \
 && cp -R /tmp/opencats/* /var/www/html/ \
 && rm -rf /tmp/opencats/.git /tmp/opencats

# Permitir .htaccess y dejar permisos
RUN sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf \
 && chown -R www-data:www-data /var/www/html

# Healthcheck para que Traefik/Coolify sepan que el web responde
HEALTHCHECK --interval=5s --timeout=5s --retries=12 --start-period=60s \
  CMD wget -qO- http://127.0.0.1/ || exit 1

CMD ["apache2-foreground"]
