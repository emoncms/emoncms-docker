ARG BUILD_FROM=php:8.4-apache

# Official Docker PHP & Apache image https://hub.docker.com/_/php/
FROM $BUILD_FROM

ARG \
    TARGETPLATFORM \
    S6_OVERLAY_VERSION=3.1.6.2 \
    S6_SRC=https://github.com/just-containers/s6-overlay/releases/download \
    S6_DIR=/etc/s6-overlay/s6-rc.d \
    PRIMOS="apache2" \
    SECONDOS="emoncms_mqtt service-runner feedwriter sync_upload" \
    EMONCMS_SRC=https://github.com/emoncms/emoncms \
    BRANCH=master \
    DAEMON=www-data \
    WWW=/var/www \
    OEM_DIR=/opt/openenergymonitor \
    EMONCMS_DIR=/opt/emoncms \
    EMONCMS_LOG_LOCATION=/var/log/emoncms \
    EMONCMS_DATADIR=/var/opt/emoncms

ENV \
    DAEMON=www-data \
    WWW=/var/www \
    OEM_DIR=/opt/openenergymonitor \
    EMONCMS_DIR=/opt/emoncms \
    EMONCMS_LOG_LOCATION=/var/log/emoncms

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        iproute2 \
        libcurl4-gnutls-dev \
        libmosquitto-dev \
        gettext \
        nano \
        git-core \
        xz-utils \
        python3 \
        python3-redis \
        default-mysql-client \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Enable PHP modules
RUN docker-php-ext-install -j$(nproc) mysqli gettext

# Install phpredis extension
COPY install_redis.sh /
RUN chmod +x /install_redis.sh && /install_redis.sh

# Install Mosquitto-PHP extension
COPY install_mosquitto.sh /
RUN chmod +x /install_mosquitto.sh && /install_mosquitto.sh

RUN a2enmod rewrite

# Add custom PHP config
COPY config/php.ini /usr/local/etc/php/

# Add custom Apache config
COPY config/emoncms.conf /etc/apache2/sites-available/emoncms.conf
RUN a2dissite 000-default.conf && a2ensite emoncms

# Install s6-overlay
RUN set -x;\
    case ${TARGETPLATFORM} in \
    "linux/amd64")  S6_ARCH="x86_64"  ;; \
    "linux/arm/v7") S6_ARCH="arm"  ;; \
    "linux/arm64")  S6_ARCH="aarch64"  ;; \
    *)              S6_ARCH="x86_64"  ;; \
    esac;\
    curl -fsSL -o /tmp/s6-overlay-${S6_ARCH}.tar.xz \
        ${S6_SRC}/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz;\
    curl -fsSL -o /tmp/s6-overlay-noarch.tar.xz \
        ${S6_SRC}/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz;\
    tar -C / -Jxpf /tmp/s6-overlay-${S6_ARCH}.tar.xz;\
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz;\
    rm -f /tmp/s6-overlay-*.tar.xz

# Clone emoncms core and modules
RUN set -x;\
    mkdir -p $OEM_DIR;\
    mkdir -p $EMONCMS_DIR/modules;\
    cd $WWW && git clone -b $BRANCH $EMONCMS_SRC;\
    cd $WWW/emoncms/Modules && git clone https://github.com/emoncms/dashboard;\
    cd $WWW/emoncms/Modules && git clone https://github.com/emoncms/graph;\
    cd $WWW/emoncms/Modules && git clone https://github.com/emoncms/app;\
    cd $WWW/emoncms/Modules && git clone https://github.com/emoncms/device;\
    cd $EMONCMS_DIR/modules && git clone https://github.com/emoncms/sync;\
    cd $EMONCMS_DIR/modules && git clone https://github.com/emoncms/postprocess;\
    cd $EMONCMS_DIR/modules && git clone https://github.com/emoncms/backup;\
    ln -s $EMONCMS_DIR/modules/sync $WWW/emoncms/Modules/sync;\
    ln -s $EMONCMS_DIR/modules/postprocess $WWW/emoncms/Modules/postprocess;\
    ln -s $EMONCMS_DIR/modules/backup $WWW/emoncms/Modules/backup;\
    chown -R $DAEMON $WWW/emoncms;\
    chown -R $DAEMON $EMONCMS_DIR

WORKDIR $OEM_DIR

RUN set -x;\
    git config --system --replace-all safe.directory '*';\
    git clone https://github.com/openenergymonitor/EmonScripts;\
    cp EmonScripts/install/emonsd.config.ini EmonScripts/install/config.ini

COPY docker.settings.ini /var/www/emoncms/settings.ini

# Create folders & set permissions for feed-engine data, logs, and worker lock files
RUN set -x;\
    mkdir -p $EMONCMS_DATADIR/phpfina;\
    mkdir -p $EMONCMS_DATADIR/phptimeseries;\
    chown -R $DAEMON $EMONCMS_DATADIR;\
    mkdir -p $EMONCMS_LOG_LOCATION;\
    chown $DAEMON $EMONCMS_LOG_LOCATION;\
    touch $EMONCMS_LOG_LOCATION/emoncms.log;\
    chmod 666 $EMONCMS_LOG_LOCATION/emoncms.log;\
    chown $DAEMON /var/lock;\
    chown $DAEMON /tmp

# Generate emoncmsdbupdate.php for schema initialisation
RUN set -x;\
    echo "<?php" > $OEM_DIR/emoncmsdbupdate.php;\
    echo "\$applychanges = true;" >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "define('EMONCMS_EXEC', 1);" >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "chdir('$WWW/emoncms');" >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "require 'process_settings.php';" >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "require 'core.php';" >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "\$mysqli = @new mysqli(" >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "    \$settings['sql']['server']," >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "    \$settings['sql']['username']," >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "    \$settings['sql']['password']," >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "    \$settings['sql']['database']," >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "    \$settings['sql']['port']" >> $OEM_DIR/emoncmsdbupdate.php;\
    echo ");" >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "require_once 'Lib/dbschemasetup.php';" >> $OEM_DIR/emoncmsdbupdate.php;\
    echo "print json_encode(db_schema_setup(\$mysqli,load_db_schema(),\$applychanges)).'\n';" >> $OEM_DIR/emoncmsdbupdate.php

COPY emoncms_pre.sh sql_ready.sh sync_upload-run.sh $OEM_DIR/

# s6-overlay: user bundle (primary services)
# sql_ready must run before Apache serves traffic (otherwise / hits user_controller with no users table).
# It was only registered in user2; in s6-overlay v3 the default target may not activate user2, so
# schema init never ran. sql_ready lives in user with emoncms_pre -> sql_ready -> apache2.
RUN set -x;\
    mkdir $S6_DIR/emoncms_pre;\
    mkdir $S6_DIR/emoncms_pre/dependencies.d;\
    touch $S6_DIR/emoncms_pre/dependencies.d/base;\
    echo "oneshot" > $S6_DIR/emoncms_pre/type;\
    echo "$OEM_DIR/emoncms_pre.sh" > $S6_DIR/emoncms_pre/up;\
    mkdir $S6_DIR/sql_ready;\
    mkdir $S6_DIR/sql_ready/dependencies.d;\
    touch $S6_DIR/sql_ready/dependencies.d/emoncms_pre;\
    echo "oneshot" > $S6_DIR/sql_ready/type;\
    echo "$OEM_DIR/sql_ready.sh" > $S6_DIR/sql_ready/up;\
    touch $S6_DIR/user/contents.d/emoncms_pre;\
    touch $S6_DIR/user/contents.d/sql_ready;\
    for i in $PRIMOS; do mkdir $S6_DIR/$i; done;\
    for i in $PRIMOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
    for i in $PRIMOS; do touch $S6_DIR/$i/dependencies.d/sql_ready; done;\
    for i in $PRIMOS; do touch $S6_DIR/user/contents.d/$i; done;\
    for i in $PRIMOS; do echo "longrun" > $S6_DIR/$i/type; done;\
    echo "#!/command/with-contenv sh" > $S6_DIR/apache2/run;\
    echo "rm -f /var/run/apache2/apache2.pid" >> $S6_DIR/apache2/run;\
    echo "exec apache2-foreground" >> $S6_DIR/apache2/run

# s6-overlay: user2 bundle (workers)
RUN set -x;\
    for i in $SECONDOS; do mkdir $S6_DIR/$i; done;\
    for i in $SECONDOS; do mkdir $S6_DIR/$i/dependencies.d; done;\
    for i in $SECONDOS; do touch $S6_DIR/$i/dependencies.d/sql_ready; done;\
    for i in $SECONDOS; do touch $S6_DIR/user2/contents.d/$i; done;\
    for i in $SECONDOS; do echo "longrun" > $S6_DIR/$i/type; done;\
    echo "#!/command/with-contenv sh" > $S6_DIR/emoncms_mqtt/run;\
    echo "exec s6-setuidgid $DAEMON php $WWW/emoncms/scripts/services/emoncms_mqtt/emoncms_mqtt.php" >> $S6_DIR/emoncms_mqtt/run;\
    echo "#!/command/with-contenv sh" > $S6_DIR/service-runner/run;\
    echo "exec s6-setuidgid $DAEMON python3 $WWW/emoncms/scripts/services/service-runner/service-runner.py" >> $S6_DIR/service-runner/run;\
    echo "#!/command/with-contenv sh" > $S6_DIR/feedwriter/run;\
    echo "if [ \"\${REDIS_BUFFER}\" -ne 1 ]; then" >> $S6_DIR/feedwriter/run;\
    echo "    echo \"FEEDWRITER IS MUTED\"" >> $S6_DIR/feedwriter/run;\
    echo "    s6-svc -O ." >> $S6_DIR/feedwriter/run;\
    echo "    exit 0" >> $S6_DIR/feedwriter/run;\
    echo "fi" >> $S6_DIR/feedwriter/run;\
    echo "exec s6-setuidgid $DAEMON php $WWW/emoncms/scripts/feedwriter.php" >> $S6_DIR/feedwriter/run;\
    cp $OEM_DIR/sync_upload-run.sh $S6_DIR/sync_upload/run;\
    chmod +x $S6_DIR/sync_upload/run;\
    chmod +x $OEM_DIR/emoncms_pre.sh;\
    chmod +x $OEM_DIR/sql_ready.sh

ENV \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
    S6_SERVICES_GRACETIME=18000

EXPOSE 80

ENTRYPOINT ["/init"]
