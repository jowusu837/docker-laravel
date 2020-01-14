This is a base image for running your laravel applications. To use this image, you simply have to create a Dockerfile in your laravel project with the following contents

```Dockerfile
FROM jowusu837/laravel:latest

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www

# Make start script executable
RUN chmod +x ./docker/start.sh

# Default command
ENTRYPOINT ["docker/start.sh"]
```
You don't necessarily need lines 9-13 so you can decide however you want to start your application. However, I prefer to use a start script as my application entrypoint because I use the same image for development, testing and production. Here's how my start script looks like:

```sh
#!/usr/bin/env bash

cd /var/www || exit

echo "Installing composer dependencies..."
composer install --ignore-platform-reqs --no-scripts

if [ "$APP_ENV" = "local" ];then
  echo "Starting development server..."
  php artisan serve --host 0.0.0.0
elif [ "$APP_ENV" = "testing" ];then
  echo "Running phpunit tests..."
  php artisan config:clear
  vendor/bin/phpunit
else
  echo "Running migrations..."
  php artisan migrate --force

  echo "Generating passpart encryption keys..."
  php artisan passport:keys

  echo "Starting supervisor..."
  /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
fi
```

You can see how I am using the `APP_ENV` environment variable to determine what scripts to run. If you decide to go this approach, make sure that you have this variable set in your docker container before running it. I normally use docker compose locally so that I can utilize a `.env` file. Here's how my `docker-compose.yml` file looks like:

```yml
version: '3'

services:
  db:
    image: mysql
    restart: unless-stopped
    tty: true
    volumes:
      - dbdata:/var/lib/mysql
      - ./docker/mysql/my.cnf:/etc/mysql/my.cnf
    environment:
      - MYSQL_ALLOW_EMPTY_PASSWORD=yes
      - MYSQL_USER=${DB_USERNAME}
      - MYSQL_DATABASE=${DB_DATABASE}
      - MYSQL_PASSWORD=${DB_PASSWORD}

  adminer:
    image: adminer
    ports:
      - "8080:8080"
    environment:
      - ADMINER_DEFAULT_SERVER=db

  redis:
    image: redis

  app:
    build: .
    restart: unless-stopped
    tty: true
    ports:
      - "8000:8000"
      - "80:80"
    volumes:
      - ./:/var/www
    environment:
      - APP_ENV=${APP_ENV}

volumes:
  dbdata:
    driver: local
```

You can see how I'm binding `APP_ENV` to the app container here; this is coming from my `.env` file. If you decide to run this without docker compose then it will look something like this:

``
docker run -e APP_ENV=testing my_image
``
