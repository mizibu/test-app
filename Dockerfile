# PHP image
FROM php:8.4-fpm

# Sistem bağımlılıkları
RUN apt-get update && apt-get install -y \
    libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev zip unzip git curl \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Node.js ve npm ekle
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Composer kur
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Proje dosyalarını kopyala
WORKDIR /var/www
COPY . .

# Build al (npm run build)
RUN npm install && npm run build

# Laravel bağımlılıklarını kur
RUN composer install --no-dev --optimize-autoloader

# Laravel için storage ve cache izinleri
RUN chown -R www-data:www-data /var/www/storage /var/www/bootstrap/cache

# Nginx yerine PHP-FPM çalışacak
CMD ["php-fpm"]