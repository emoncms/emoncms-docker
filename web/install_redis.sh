#!/bin/bash

# Install Redis
cd /
git clone --depth 1 -b ${PHPREDIS_VERSION:-6.3.0} https://github.com/phpredis/phpredis
cd phpredis
phpize
./configure
make
make install
docker-php-ext-enable redis
