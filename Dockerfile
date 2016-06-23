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

# Add custom PHP config
COPY config/php.ini /usr/local/etc/php/

# Copy in emoncms files, files can be mounted from local FS for dev see docker-compose
ADD ./emoncms /var/www/html

# Copy in docker settings
ADD docker.settings.php /var/www/html
WORKDIR /var/www/html
RUN cp docker.settings.php settings.php

# Create folders & set permissions for feed-engine data folders (mounted as docker volumes in docker-compose)
RUN mkdir /var/lib/phpfiwa
RUN mkdir /var/lib/phpfina
RUN mkdir /var/lib/phptimeseries
RUN chown www-data:root /var/lib/phpfiwa
RUN chown www-data:root /var/lib/phpfina
RUN chown www-data:root /var/lib/phptimeseries

# Create Emoncms logfile
RUN touch /var/log/emoncms.log
RUN chmod 666 /var/log/emoncms.log


# TODO
# consider alpine lightweight image
# Add Pecl :
# - dio
# - Swiftmailer
# php timezone https://github.com/emoncms/emoncms/blob/master/docs/LinuxInstall.md#configure-php-timezone