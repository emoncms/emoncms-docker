#!/bin/bash
# Disable bluetooth device and restores UART0/ttyAMA0
# once the device tree overlay setting is added to the /boot/config.txt the host must reboot

set -e

# test for env var 
if [ -z "$REBOOT_HOST_TOGGLE" ]; then
  cat >&2 <<EOF
A REBOOT_HOST_TOGGLE is required to run this container.
EOF
  exit 1
fi

# check for reboot request status, reboot if required
if [ -e $REBOOT_HOST_TOGGLE ]
then
    # remove reboot toggle to prevent reboot on next boot
    rm ${REBOOT_HOST_TOGGLE}
    # disable bluetooth - add device tree overlay line on host /boot/config.txt
    sed -i -n '/dtoverlay=pi3-disable-bt/!p;$a dtoverlay=pi3-disable-bt' /boot/config.txt
    # send signal to host
    echo "reboot" > /shutdown_signal
else
    python2 ${EMONHUB_DIR}/src/emonhub.py
fi

exec "$@"
