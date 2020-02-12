FROM php:7.3.9-cli

RUN apt-get update && apt-get install -y libmosquitto-dev gettext

RUN docker-php-ext-install -j$(nproc) mysqli gettext json

RUN pecl install redis \
  \ && docker-php-ext-enable redis
RUN pecl install Mosquitto-beta \
  \ && docker-php-ext-enable mosquitto
