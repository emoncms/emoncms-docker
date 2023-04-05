#!/bin/bash

# Install Redis
cd /
git clone https://github.com/phpredis/phpredis
cd phpredis
phpize
./configure
make
make install
docker-php-ext-enable redis
