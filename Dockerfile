# Offical Docker PHP & Apache image https://hub.docker.com/_/php/
FROM php:5.6-apache

# Install deps
RUN apt-get update && apt-get install -y \
              libcurl4-gnutls-dev \
              php5-curl \
              php5-json \
              php5- mcrypt \
              php5-mysql \
              libmcrypt-dev \
    # Enable PHP modules
     && docker-php-ext-install -j$(nproc) mysql mysqli curl json mcrypt gettext

RUN a2enmod rewrite

# Copy in emoncms files, files can be mounted from local FS for dev see docker-compose
ADD ./emoncms /var/www/html

# Copy in docker settings
ADD docker.settings.php /var/www/html
WORKDIR /var/www/html
RUN cp docker.settings.php settings.php

# TODO
# consider alpine lightweight image
# Add Pecl :
# - dio
# - Swiftmailer
# php timezone https://github.com/emoncms/emoncms/blob/master/docs/LinuxInstall.md#configure-php-timezone