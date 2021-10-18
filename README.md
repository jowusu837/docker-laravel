# Docker of Laravel

[![License](https://img.shields.io/badge/license-MIT-%233DA639.svg)](https://opensource.org/licenses/MIT)

This is a base image for running your laravel applications. To use this image, you simply have to create a Dockerfile in your laravel project with the following contents

```Dockerfile
FROM jowusu837/laravel:latest

# Copy existing application directory permissions
COPY --chown=www-data:www-data . /var/www
```
Or you can use docker compose like so:

```yml
version: '3'

services:
  ...
  app:
    image: jowusu837/laravel:latest
    ports:
      - "8000:8000"
    volumes:
      - ./:/var/www
    environment:
      - APP_ENV=${APP_ENV}
    ...
```

## Testing
The image has 3 modes configured: development, testing and production. You switch between modes using `APP_ENV` environment variable. If you are using docker compose, this will be in sync with what you already have in your `.env` file. I suggest you use docker compose locally though.

Say you want to run your app with docker in testing mode:
``
docker run -e APP_ENV=testing my_image
``
