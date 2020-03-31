## non arm32 bit
ARG MYSQL_DOCKER_IMAGE
FROM ${MYSQL_DOCKER_IMAGE}
# comment out "..only listening the localhost.."
RUN if [ -f /etc/mysql/mariadb.conf.d/50-server.cnf ]; then sed -i "s/^bind-address/#bind-address/g" /etc/mysql/mariadb.conf.d/50-server.cnf; fi
