FROM httpd:2.4-alpine

RUN apk update; apk upgrade;

# Copy apache vhost file to proxy php requests to php-fpm container
COPY emoncms.conf /usr/local/apache2/conf/emoncms.conf
RUN echo "Include /usr/local/apache2/conf/emoncms.conf" >> /usr/local/apache2/conf/httpd.conf

RUN sed -i '/LoadModule rewrite_module/s/^#//g' /usr/local/apache2/conf/httpd.conf
