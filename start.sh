#!/usr/bin/env bash

if [ "$APP_ENV" = "local" ];then
  cd /var/www && php artisan serve --host 0.0.0.0
elif [ "$APP_ENV" = "testing" ];then
  cd /var/www || exit
  php artisan config:clear
  vendor/bin/phpunit
else
  php artisan migrate --force
  php artisan passport:keys
  /usr/bin/supervisord -n -c /etc/supervisor/conf.d/supervisord.conf
fi