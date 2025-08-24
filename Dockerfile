# Dockerfile
FROM php:7.4-apache

# Paquetes del sistema que usa OpenCATS (y el indexado de CVs)
RUN apt-get update && apt-get install -y \
    git unzip curl \
    antiword poppler-utils html2text unrtf \
    libxml2-dev \
 && rm -rf /var/lib/apt/lists/*

# Extensiones PHP que OpenCATS usa
RUN docker-php-ext-install mysqli \
 && docker-php-ext-install soap || true   # SOAP es opcional

# Activar módulos de Apache que OpenCATS necesita
RUN a2enmod rewrite headers

# Copia el código de la app al document root
# (si tu código no está en la raíz, ajusta la ruta del COPY)
COPY . /var/www/html

# Instalar Composer y dependencias de PHP (crea vendor/)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --prefer-dist -o --working-dir=/var/www/html

# Permisos correctos para Apache
RUN chown -R www-data:www-data /var/www/html

# Healthcheck simple
HEALTHCHECK --interval=30s --timeout=5s --retries=10 CMD curl -fsS http://localhost/ || exit 1
