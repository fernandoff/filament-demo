# Usar a imagem oficial do PHP 8.2 com Apache
FROM php:8.2-apache

# Definir o diretório de trabalho
WORKDIR /var/www/html

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libonig-dev \
    libxml2-dev \
    libzip-dev \
    libicu-dev \
    zip \
    curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo pdo_mysql mbstring exif pcntl bcmath gd zip intl

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copiar o arquivo composer.json e composer.lock
COPY composer.json composer.lock ./

# Instalar dependências do Composer
RUN composer install --no-scripts --no-autoloader --ignore-platform-reqs

# Copiar o restante da aplicação
COPY . .

# Gerar autoload do Composer
RUN composer dump-autoload --optimize

# Configurar permissões
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 755 /var/www/html
RUN chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# Copiar a configuração personalizada do Apache
COPY apache-vhost.conf /etc/apache2/sites-available/000-default.conf

# Habilitar o módulo rewrite do Apache
RUN a2enmod rewrite

# Expor a porta 80
EXPOSE 80

# Comando para iniciar o servidor Apache
CMD ["apache2-foreground"]
