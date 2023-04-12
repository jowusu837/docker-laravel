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
  # Optimize config loading
  php artisan config:cache

  # Optimize route loading
  php artisan route:cache

  # Cache views
  php artisan view:cache

  echo "Running migrations..."
  php artisan migrate --force

  echo "Starting supervisor..."
  /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
fi
