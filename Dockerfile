# Dockerfile
FROM php:7.4-apache

# Paquetes del sistema (incluye utilerías de indexado)
RUN apt-get update && apt-get install -y \
    git unzip curl \
    antiword poppler-utils html2text unrtf \
    libxml2-dev \
 && rm -rf /var/lib/apt/lists/*

# Extensiones PHP necesarias
RUN docker-php-ext-install mysqli \
 && docker-php-ext-install soap || true

# Activa módulos de Apache
RUN a2enmod rewrite headers

# Trabajaremos en /var/www/html
WORKDIR /var/www/html

# --- DESCARGA DEL CÓDIGO DE OPENCATS ---
# Puedes fijar una rama o tag si quieres; por ahora master (o main).
ARG OPENCATS_REPO=https://github.com/opencats/OpenCATS.git
ARG OPENCATS_REF=master
RUN rm -rf /var/www/html/* \
 && git clone --depth 1 --branch ${OPENCATS_REF} ${OPENCATS_REPO} /tmp/opencats \
 && rsync -a /tmp/opencats/ /var/www/html/ \
 && rm -rf /tmp/opencats/.git

# Composer (genera vendor/)
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --prefer-dist -o

# Asegura carpetas persistentes y permisos
RUN mkdir -p /var/www/html/attachments /var/www/html/careerportal \
 && chown -R www-data:www-data /var/www/html

# Healthcheck simple
HEALTHCHECK --interval=30s --timeout=5s --retries=10 CMD curl -fsS http://localhost/ || exit 1
