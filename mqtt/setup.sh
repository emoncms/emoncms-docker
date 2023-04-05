# Disable mosquitto persistance
sed -i "s/^persistence true/persistence false/" /mosquitto/config/mosquitto.conf
# append line: allow_anonymous false
sed -i -n '/allow_anonymous false/!p;$a allow_anonymous false' /mosquitto/config/mosquitto.conf
# append line: password_file /etc/mosquitto/passwd
sed -i -n '/password_file \/mosquitto\/config\/passwd/!p;$a password_file \/mosquitto\/config\/passwd' /mosquitto/config/mosquitto.conf
# append line: log_type error
sed -i -n '/log_type error/!p;$a log_type error' /mosquitto/config/mosquitto.conf

# Create mosquitto password file
touch /mosquitto/config/passwd
mosquitto_passwd -b /mosquitto/config/passwd emonpi emonpimqtt2016
