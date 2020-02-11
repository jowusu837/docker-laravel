#!/usr/bin/env bash

cd /var/www || exit

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
