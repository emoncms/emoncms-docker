#!/bin/bash
# HOST MACHINE REBOOT INTERFACE
# listen for changes to $SIGNAL_FILE. 
# if $SIGNAL_FILE contents === "true", system reboots
#
# thanks to [mat](https://stackoverflow.com/users/1318694/matt)
# https://stackoverflow.com/users/1318694/matt

SIGNAL_FILE=./shutdown_signal

echo "waiting" > $SIGNAL_FILE
while inotifywait -e close_write $SIGNAL_FILE; do 
  signal=$(cat $SIGNAL_FILE)
  if [ "$signal" == "shutdown" ]; then 
    sudo echo "shutdown done" > file
    echo "----------shutting down..."
    sudo shutdown -h now
  elif [ "$signal" == "reboot" ]; then
    sudo echo "reboot done" > file
    echo "----------rebooting..."
    sudo shutdown -r now
  elif [ "$signal" == "restart-emonhub" ]; then
    sudo echo "restarted emonhub" > file
    echo "----------restarting emonhub..."
    docker-compose restart emonhub
  fi
done
