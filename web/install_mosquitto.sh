#!/bin/bash

# Install Mosquitto
cd /
apt-get install -y libmosquitto-dev
git clone https://github.com/openenergymonitor/Mosquitto-PHP
cd Mosquitto-PHP/
phpize
./configure
make
make install
docker-php-ext-enable mosquitto

