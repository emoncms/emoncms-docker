ARG BUILD_FROM=php:8.0-apache

# Offical Docker PHP & Apache image https://hub.docker.com/_/php/
FROM $BUILD_FROM

ARG \
    EMONCMS_SRC=https://github.com/emoncms/emoncms \
    BRANCH=master \
    DAEMON=www-data \
    WWW=/var/www \
    OEM_DIR=/opt/openenergymonitor \
    EMONCMS_DIR=/opt/emoncms \
    EMONCMS_LOG_LOCATION=/var/log/emoncms \
    EMONCMS_DATADIR=/var/opt/emoncms
    

# Install deps
RUN apt-get update && apt-get install -y \
              iproute2 \
              libcurl4-gnutls-dev \
              libmcrypt-dev \
              gettext \
              nano \
              git-core \
              supervisor

# Enable PHP modules
RUN docker-php-ext-install -j$(nproc) mysqli gettext

# Install redis
COPY install_redis.sh /
RUN chmod +x /install_redis.sh
RUN /install_redis.sh

# Install mosquitto
COPY install_mosquitto.sh /
RUN chmod +x /install_mosquitto.sh
RUN /install_mosquitto.sh

RUN a2enmod rewrite

# Add custom PHP config
COPY config/php.ini /usr/local/etc/php/

# Add custom Apache config
COPY config/emoncms.conf /etc/apache2/sites-available/emoncms.conf
RUN a2dissite 000-default.conf
RUN a2ensite emoncms

# Clone in master Emoncms repo & modules - overwritten in development with local FS files
RUN \
    set -x;\
    mkdir -p $OEM_DIR;\
    cd $WWW && git clone -b $BRANCH $EMONCMS_SRC;\
    cd $WWW/emoncms/Modules && git clone https://github.com/emoncms/dashboard;\
    cd $WWW/emoncms/Modules && git clone https://github.com/emoncms/graph;\
    cd $WWW/emoncms/Modules && git clone https://github.com/emoncms/app;\
    cd $WWW/emoncms/Modules && git clone https://github.com/emoncms/device;\
    chown -R $DAEMON $WWW/emoncms

WORKDIR $OEM_DIR

RUN \
    set -x;\
    git config --system --replace-all safe.directory '*';\
    git clone https://github.com/openenergymonitor/EmonScripts;\
    cp EmonScripts/install/emonsd.config.ini EmonScripts/install/config.ini

COPY docker.settings.ini /var/www/emoncms/settings.ini

# Create folders & set permissions for feed-engine data folders (mounted as docker volumes in docker-compose)
RUN \
    set -x;\
    mkdir $EMONCMS_DATADIR;\
    mkdir $EMONCMS_DATADIR/phpfina;\
    mkdir $EMONCMS_DATADIR/phptimeseries;\
    chown -R $DAEMON $EMONCMS_DATADIR

# Create Emoncms logfile
RUN \
    set -x;\
    mkdir -p $EMONCMS_LOG_LOCATION;\
    chown $DAEMON $EMONCMS_LOG_LOCATION;\
    touch $EMONCMS_LOG_LOCATION/emoncms.log;\
    chmod 666 $EMONCMS_LOG_LOCATION/emoncms.log

# To start Apache and emoncms_mqtt from supervisord
COPY config/supervisord.conf /etc/supervisor/supervisord.conf
ENTRYPOINT [ "/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf" ]
