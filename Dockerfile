FROM php:7.2-fpm-stretch

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    mysql-client \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    supervisor \
    net-tools \
    nginx \
    cron

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install other php extensions
RUN docker-php-ext-install pdo_mysql mbstring zip exif pcntl
RUN docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-png-dir=/usr/include/
RUN docker-php-ext-install gd

# Install xdebug
RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Remove default nginx site
RUN rm /etc/nginx/sites-enabled/default;

# Copy configuration files
COPY laravel.ini /usr/local/etc/php/conf.d/
COPY laravel.pool.conf /usr/local/etc/php-fpm.d/
COPY supervisord.conf /etc/supervisor/conf.d/
COPY default.conf /etc/nginx/conf.d/
COPY scheduler /etc/cron.d/scheduler

# Run the cron
RUN crontab /etc/cron.d/scheduler
