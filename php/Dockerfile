ARG PHP_VERSION
FROM php:${PHP_VERSION}-fpm

ARG EMONCMS_DIR
ARG EMONCMS_WEB_DIR
ARG PHPFINA_DIR
ARG PHPTIMESERIES_DIR
ARG EMONCMS_DATA_DIR
ARG LOG_LOCATION

RUN apt-get update && apt-get install --no-install-recommends -y gettext libmosquitto-dev git-core

RUN docker-php-ext-install -j$(nproc) mysqli gettext

RUN pecl install redis \
    && docker-php-ext-enable redis
RUN pecl install Mosquitto-beta \
    && docker-php-ext-enable mosquitto

RUN git clone https://github.com/emrysr/emoncms.git ${EMONCMS_WEB_DIR} \
    && git clone https://github.com/emoncms/dashboard.git ${EMONCMS_WEB_DIR}/Modules/dashboard \
    && git clone https://github.com/emoncms/graph.git ${EMONCMS_WEB_DIR}/Modules/graph \
    && git clone https://github.com/emoncms/device.git ${EMONCMS_WEB_DIR}/Modules/device \
    && git clone https://github.com/emoncms/app.git ${EMONCMS_WEB_DIR}/Modules/app

COPY ./docker.settings.ini ${EMONCMS_WEB_DIR}/settings.ini

RUN mkdir -p ${EMONCMS_DIR} \
    && git clone https://github.com/emoncms/backup.git ${EMONCMS_DIR}/backup \
    && git clone https://github.com/emoncms/sync.git ${EMONCMS_DIR}/sync

RUN ln -s ${EMONCMS_DIR}/backup/backup-module ${EMONCMS_WEB_DIR}/Modules/backup \
    && ln -s ${EMONCMS_DIR}/sync/sync-module ${EMONCMS_WEB_DIR}/Modules/sync \
    && mv ${EMONCMS_DIR}/backup/default.config.cfg ${EMONCMS_DIR}/backup/config.cfg

# Create folders & set permissions for feed-engine data folders (mounted as docker volumes in docker-compose)
RUN mkdir -p ${PHPFINA_DIR} \
    && mkdir -p ${PHPTIMESERIES_DIR} \
    && chown -R www-data: ${EMONCMS_DATA_DIR}

# Create Emoncms logfile
RUN mkdir ${LOG_LOCATION} \
    && touch ${LOG_LOCATION}/emoncms.log \
    && chmod 666 ${LOG_LOCATION}/emoncms.log
