FROM eclipse-mosquitto:2.0
COPY mosquitto.conf /mosquitto/config/mosquitto.conf
COPY setup.sh /
RUN chmod +x /setup.sh
RUN /setup.sh
