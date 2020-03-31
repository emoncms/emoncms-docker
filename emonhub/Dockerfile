FROM python:3.8-slim
ARG EMONCMS_WEB_DIR
ARG EMONCMS_DIR
ARG EMONHUB_DIR
ARG REBOOT_HOST_TOGGLE
ARG EMONHUB_LOG

COPY connected.py /
COPY entrypoint.sh /

RUN ( [ ! -z "$EMONHUB_LOG" ] && [ ! -w $EMONHUB_LOG ] ) && { mkdir -p `dirname $EMONHUB_LOG`; touch $EMONHUB_LOG; }
RUN apt-get update && apt-get install -y git python-serial python-configobj python-requests build-essential python-pip
# RUN apt-get update && apt-get install -y python3-rpi.gpio

# output to std out (access via: $ docker logs emoncms-docker_emonhub_1)
RUN ( [ -w $EMONHUB_LOG ] ) && ln -sf /dev/stdout $EMONHUB_LOG 

# -----------REMOVE REF TO /emrysr IN GIT REPO ONCE TESTED !!---------------
RUN git clone https://github.com/emrysr/emonhub.git ${EMONHUB_DIR} \
    && git clone https://github.com/emoncms/config.git ${EMONCMS_WEB_DIR}/Modules/config
# RUN git clone https://github.com/openenergymonitor/emonhub.git ${EMONHUB_DIR} \
#    && git clone https://github.com/emoncms/config.git ${EMONCMS_WEB_DIR}/Modules/config

RUN pip install rpi.gpio configobj pyserial
RUN pip2 install paho-mqtt
RUN echo "reboot" > $REBOOT_HOST_TOGGLE
ENTRYPOINT ["/entrypoint.sh"]
