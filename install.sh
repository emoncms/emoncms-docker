#!/bin/bash
# intended to be ran on a raspberry pi

# ADD SIGNAL FILE & inotify PACKAGE
# ---------------
sudo apt-get update && sudo apt-get install -y inotify-tools
FILE=./shutdown_signal
sudo touch $FILE
sudo chmod 777 $FILE

# EDIT rc.local
# --------------
# run watcher script on boot...
#   looks for blank line before "exit 0" and adds host-shutdown-interface.sh before it 
#   can only be ran once as there will not be a blank line before the "exit 0" line

DIR="$(cd "$(dirname "$0")" && pwd)"
sudo perl -i -0pe "s|\n\nexit 0|\n\n\sudo bash $DIR/host-shutdown-interface.sh &\nexit 0|" /etc/rc.local

curl -sSL https://get.docker.com | sh
sudo usermod -aG docker pi


# INSTALL DOCKER AND GIT
--------------
sudo apt-get update && sudo apt-get install -y libffi-dev libssl-dev python3 python3-pip
sudo pip3 install docker-compose

echo "--------------------------"
echo "DONE"
echo "--------------------------"
echo "once rebooted the emonhub will be available at:"
ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'|tail -n1
echo "--------------------------"
read -n 1 -s -r -p "Press any key to reboot"

# HOST SHUTDOWN
--------------
# run the host-shutdown-interface.sh before running the docker containers
# (/etc/rc.local will restart it on next boot)
./host-shutdown-interface.sh &

# DOCKER COMPOSE
# --------------
# run all containers in detached mode (will restart on reboot)
docker-compose up -d

