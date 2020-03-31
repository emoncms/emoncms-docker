#!/bin/bash
# intended to be ran on docker host
sudo apt-get update

curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi
# reboot required to enable new user group

sudo apt-get install -y python3 python3-pip git-core
sudo pip3 install docker-compose

git clone https://github.com/TrystanLea/emoncms-docker-fpm && cd emoncms-docker-fpm
git checkout -b stage1-5-emonhub && git pull origin stage1-5-emonhub

# ----------------------------------------------------------------------------------------
# RaspberryPi Serial configuration
# disable Pi3 Bluetooth and restore UART0/ttyAMA0 over GPIOs 14 & 15;
# Review should this be: dtoverlay=pi3-miniuart-bt?
sudo sed -i -n '/dtoverlay=pi3-disable-bt/!p;$a dtoverlay=pi3-disable-bt' /boot/config.txt

# We also need to stop the Bluetooth modem trying to use UART
sudo systemctl disable hciuart

# Remove console from /boot/cmdline.txt
sudo sed -i "s/console=serial0,115200 //" /boot/cmdline.txt

# stop and disable serial service??
sudo systemctl stop serial-getty@ttyAMA0.service
sudo systemctl disable serial-getty@ttyAMA0.service
sudo systemctl mask serial-getty@ttyAMA0.service
# ----------------------------------------------------------------------------------------

docker-compose up
