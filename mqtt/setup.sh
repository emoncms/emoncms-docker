# Create mosquitto password file
touch /mosquitto/config/passwd
mosquitto_passwd -b /mosquitto/config/passwd emonpi emonpimqtt2016
