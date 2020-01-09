#!/usr/bin/env bash

echo "Installing composer dependencies..."
composer install --ignore-platform-reqs --no-scripts

if [ "$APP_ENV" = "local" ];then
  echo "Starting development server..."
  cd /var/www && php artisan serve --host 0.0.0.0
elif [ "$APP_ENV" = "testing" ];then
  cd /var/www || exit

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