FROM php:7.4-fpm

LABEL maintainer="Victor J. Owusu <jowusu837@gmail.com>"

# Set working directory
WORKDIR /var/www

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    locales \
    libzip-dev \
    zlib1g-dev \
    vim \
    unzip \
    git \
    curl \
    supervisor \
    net-tools \
    nginx

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN pecl install redis && \
    docker-php-ext-install pdo_mysql mbstring zip exif pcntl redis && \
    docker-php-ext-enable pdo_mysql redis

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Copy required files
COPY laravel.ini /usr/local/etc/php/conf.d/
COPY laravel.pool.conf /usr/local/etc/php-fpm.d/
COPY supervisord.conf /etc/supervisor/conf.d/
COPY nginx/default.conf /etc/nginx/conf.d/
COPY start.sh /usr/local/bin/start-laravel.sh

# Setup nginx && start script
RUN rm /etc/nginx/sites-enabled/default && \
    chmod +x /usr/local/bin/start-laravel.sh

# Default command
ENTRYPOINT ["/usr/local/bin/start-laravel.sh"]

EXPOSE 80 8000