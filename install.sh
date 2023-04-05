#!/bin/bash

# Install Redis
git clone https://github.com/phpredis/phpredis
cd phpredis
phpize
./configure
make
make install
docker-php-ext-enable redis

# Install Mosquitto
apt-get install -y libmosquitto-dev
git clone https://github.com/openenergymonitor/Mosquitto-PHP
cd Mosquitto-PHP/
phpize
./configure
make
make install
# Add mosquitto to php mods available
# PHP_VER=$(php -v | head -n 1 | cut -d " " -f 2 | cut -f1-2 -d"." )
# printf "extension=mosquitto.so" | tee /etc/php/$PHP_VER/mods-available/mosquitto.ini 1>&2
# phpenmod mosquitto
docker-php-ext-enable mosquitto

