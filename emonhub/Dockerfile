FROM python:3.8-slim

ARG EMONHUB_DIR

RUN apt-get update && apt-get install -y git python3-serial python3-configobj python3-pip
RUN pip3 install paho-mqtt requests configobj pyserial

RUN git clone -b python3 https://github.com/openenergymonitor/emonhub.git ${EMONHUB_DIR}

RUN mkdir -p /etc/emonhub
COPY ./emonhub.conf /etc/emonhub/emonhub.conf
