#!/bin/bash -e

## Create signalK user to run the server.
if [ ! -d /home/signalk ]; then
	echo "Creating signalk user"
	adduser --home /home/signalk --gecos --system --disabled-password --disabled-login signalk
fi

usermod -a -G tty signalk
usermod -a -G i2c signalk
usermod -a -G spi signalk
usermod -a -G gpio signalk
usermod -a -G dialout signalk
usermod -a -G plugdev signalk
usermod -a -G lirc signalk

## Create the charts group and add users that have to write to that folder.
if ! grep -q charts /etc/group; then
	groupadd charts
	usermod -a -G charts signalk
	usermod -a -G charts user
	usermod -a -G charts root
fi

## Create the special charts folder.
install -v -d -m 6775 -o signalk -g charts /srv/charts

## Link the chart folder to home for convenience.
if [ ! -f /home/user/charts ] ; then
	su user -c "ln -s /srv/charts /home/user/charts"
fi

## Dependencies of signalK.
apt-get install -y -q python3-dev git nodejs \
 libnss-mdns avahi-utils \
 node-abstract-leveldown node-nan libzmq3-dev libkrb5-dev libavahi-compat-libdnssd-dev jq

install -d -m 755 -o signalk -g signalk "/home/signalk/.signalk"
install -d -m 755 -o signalk -g signalk "/home/signalk/.signalk/plugin-config-data"
install -d -m 755 -o signalk -g signalk "/home/signalk/.signalk/node_modules/"

install -m 644 -o signalk -g signalk "$FILE_FOLDER"/set-system-time.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/sk-to-nmea0183.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/signalk-path-filter.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/derived-data.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/charts.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/anchoralarm.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/autopilot.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/signalk-navtex-plugin.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/simple-notifications.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/freeboard-sk-helper.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/freeboard-sk.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/resources-provider.json "/home/signalk/.signalk/plugin-config-data/"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/xdrParser-plugin.json "/home/signalk/.signalk/plugin-config-data/"

install -m 644 -o signalk -g signalk "$FILE_FOLDER"/defaults.json "/home/signalk/.signalk/defaults.json"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/package.json "/home/signalk/.signalk/package.json"
install -m 644 -o signalk -g signalk "$FILE_FOLDER"/settings.json "/home/signalk/.signalk/settings.json"
install -m 755 -o signalk -g signalk "$FILE_FOLDER"/signalk-server "/home/signalk/.signalk/signalk-server"
install -m 755 "$FILE_FOLDER"/signalk-restart "/usr/local/sbin/signalk-restart"

install -d -o signalk -g signalk "/home/user/.local/share/icons/"
install -m 644 -o 1000 -g 1000 "$FILE_FOLDER"/icons/signalk.png "/home/user/.local/share/icons/"

install -d /etc/systemd/system
install -m 644 "$FILE_FOLDER"/signalk.service "/etc/systemd/system/signalk.service"

## Install signalK
npm cache clean --force
npm install -g npm pnpm patch-package typescript node-gyp
npm install -g --unsafe-perm --production signalk-server@2.13.2

if [ "$BBN_KIND" == "LITE" ] ; then
  ## Install signalK published plugins
  pushd /home/signalk/.signalk
    su signalk --shell=/bin/bash -c "export MAKEFLAGS='-j 8'; \
                 export NODE_ENV=production; \
                 pnpm install \
                 @signalk/resources-provider \
                 @signalk/charts-plugin  \
                 @signalk/course-provider \
                 signalk-raspberry-pi-bme280  \
                 signalk-raspberry-pi-bmp180  \
                 signalk-raspberry-pi-ina219  \
                 signalk-raspberry-pi-1wire  \
                 signalk-venus-plugin  \
                 signalk-mqtt-gw  \
                 signalk-derived-data  \
                 signalk-anchoralarm-plugin  \
                 signalk-alarm-silencer  \
                 signalk-simple-notifications  \
                 signalk-to-nmea2000  \
                 signalk-sonoff-ewelink  \
                 signalk-shelly \
                 @mxtommy/kip  \
                 nmea0183-to-nmea0183 \
                 xdr-parser-plugin \
                 signalk-path-filter \
                 signalk-datetime \
                 @meri-imperiumi/signalk-autostate --unsafe-perm --loglevel error"
  popd
else
  ## Install signalK published plugins
  pushd /home/signalk/.signalk
    su signalk --shell=/bin/bash -c "export MAKEFLAGS='-j 8'; \
                 export NODE_ENV=production; \
                 pnpm install \
                 @signalk/resources-provider \
                 @signalk/charts-plugin  \
                 @signalk/course-provider \
                 signalk-pmtiles-plugin \
                 signalk-raspberry-pi-bme280  \
                 signalk-raspberry-pi-bmp180  \
                 signalk-raspberry-pi-ina219  \
                 signalk-raspberry-pi-1wire  \
                 signalk-venus-plugin  \
                 signalk-mqtt-gw  \
                 signalk-mqtt-home-asisstant  \
                 @codekilo/signalk-modbus-client  \
                 signalk-derived-data  \
                 signalk-anchoralarm-plugin  \
                 signalk-alarm-silencer  \
                 signalk-simple-notifications  \
                 signalk-wilhelmsk-plugin  \
                 signalk-to-nmea2000  \
                 @signalk/signalk-autopilot  \
                 @signalk/signalk-node-red  \
                 node-red-dashboard \
                 node-red-contrib-nmea \
                 node-red-contrib-modbus \
                 @victronenergy/node-red-contrib-victron \
                 node-red-contrib-influxdb \
                 node-red-contrib-moment \
                 node-red-contrib-string \
                 node-red-node-email \
                 node-red-node-serialport \
                 node-red-node-openweathermap \
                 node-red-contrib-dht-sensor \
                 node-red-contrib-ds18b20-sensor \
                 node-red-contrib-sht31 \
                 @rakwireless/shtc3 \
                 node-red-contrib-bme280 \
                 node-red-contrib-sensor-htu21d \
                 node-red-contrib-ina-sensor \
                 signalk-sonoff-ewelink  \
                 signalk-raspberry-pi-monitoring  \
                 @mxtommy/kip  \
                 signalk-barometer-trend  \
                 @oehoe83/signalk-raspberry-pi-bme680  \
                 signalk-barograph \
                 signalk-polar \
                 signalk-scheduler \
                 openweather-signalk \
                 ocearo-ui \
                 signalk-noaa-weather \
                 xdr-parser-plugin \
                 signalk-to-influxdb \
                 nmea0183-to-nmea0183 \
                 signalk-path-filter \
                 signalk-empirbusnxt-plugin \
                 obd2-signalk \
                 signalk-n2k-switch-alias \
                 signalk-n2k-switching \
                 signalk-n2k-switching-emulator \
                 signalk-n2k-switching-translator \
                 signalk-n2k-virtual-switch \
                 signalk-switch-automation \
                 signalk-shelly \
                 @signalk/calibration \
                 @signalk/tracks-plugin \
                 signalk-datetime \
                 signalk-net-relay \
                 signalk-path-mapper \
                 signalk-healthcheck \
                 @signalk/vedirect-serial-usb \
                 @signalk/udp-nmea-plugin \
                 signalk-n2kais-to-nmea0183 \
                 @codekilo/nmea0183-iec61121-450-server \
                 signalk-generic-pgn-parser \
                 signalk-maretron-proprietary \
                 signalk-vessels-to-ais \
                 @codekilo/signalk-notify \
                 @codekilo/signalk-trigger-event \
                 @codekilo/signalk-twilio-notifications \
                 @meri-imperiumi/signalk-audio-notifications \
                 signalk-buddylist-plugin \
                 signalk-navtex-plugin \
                 @meri-imperiumi/signalk-autostate \
                 @meri-imperiumi/signalk-alternator-engine-on \
                 signalk-saillogger --unsafe-perm --loglevel error"
  popd
fi

#d_old=$(pwd)
#su signalk --shell=/bin/bash -c ' export MAKEFLAGS="-j 8"; \
#  export NODE_ENV=production; \
#  for i in /home/signalk/.signalk/node_modules/.pnpm/*/node_modules/sqlite3 ; \
#  do cd $i; pnpm run rebuild; cd /home/signalk/.signalk/node_modules/.pnpm; done'
#cd $d_old

sed -i "s#sudo ##g" /home/signalk/.signalk/node_modules/signalk-raspberry-pi-monitoring/index.js || true
sed -i "s#/opt/vc/bin/##g" /home/signalk/.signalk/node_modules/signalk-raspberry-pi-monitoring/index.js || true
sed -i 's#@signalk/server-admin-ui#admin#' "$(find /usr/lib/node_modules/signalk-server -name tokensecurity.js)" || true

# see https://github.com/SignalK/signalk-server/pull/1455/
sed -i 's/\(filter(.*\]\)/"".join\(\1\)/'  "$(find /usr/lib/node_modules/signalk-server -name pigpio-seatalk.js)" || true

# use pnpm instead of npm
sed -i 's#('"'npm',#\('pnpm'"',#' /usr/lib/node_modules/signalk-server/lib/modules.js

# SignalK fix for pnpm
sed -i -e s/--save"'",/"--save-prod'",/g /usr/lib/node_modules/signalk-server/lib/modules.js

## Give set-system-time the possibility to change the date.
{
  echo "signalk ALL=(ALL) NOPASSWD: /bin/date";
  echo "signalk ALL=(ALL) NOPASSWD: /usr/bin/date";
  echo "signalk ALL=(ALL) NOPASSWD: /bin/timedatectl";
  echo "signalk ALL=(ALL) NOPASSWD: /usr/bin/timedatectl";
} >>/etc/sudoers

## Make some space on the drive for the next stages
npm cache clean --force

# For Seatalk
systemctl disable pigpiod

# For Seatalk
wget -q -O - https://raw.githubusercontent.com/MatsA/seatalk1-to-NMEA0183/master/STALK_read.py > /usr/local/sbin/STALK_read.py

echo "" >>/etc/sudoers
echo 'user ALL=(ALL) NOPASSWD: /usr/local/sbin/signalk-restart' >>/etc/sudoers

systemctl enable signalk

install -d /usr/local/share/applications

if [ "$BBN_KIND" == "LITE" ] ; then
  true
else
  bash -c 'cat << EOF > /usr/local/share/applications/signalk-node-red.desktop
[Desktop Entry]
Type=Application
Name=SignalK-Node-Red
GenericName=SignalK-Node-Red
Comment=SignalK-Node-Red
Exec=gnome-www-browser http://localhost:3000/@signalk/signalk-node-red
Terminal=false
Icon=gtk-no
Categories=Utility;
EOF'
  bash -c 'cat << EOF > /usr/local/share/applications/signalk-polar.desktop
[Desktop Entry]
Type=Application
Name=SignalK-Polar
GenericName=SignalK-Polar
Comment=SignalK-Polar
Exec=gnome-www-browser http://localhost:3000/signalk-polar
Terminal=false
Icon=gtk-about
Categories=Utility;
EOF'
fi

rm -rf /home/signalk/.cache
rm -rf /home/signalk/.npm
rm -rf /home/signalk/.node-*

if [ "$BBN_KIND" == "LITE" ] ; then
  exit 0
fi

bash -c 'cat << EOF > /usr/local/bin/gps-loc
#!/bin/bash
curl -s http://localhost:3000/signalk/v1/api/vessels/self/navigation/position/ | jq -M -jr '\''.value.latitude," ",.value.longitude','" ",.timestamp'\''
EOF'
chmod +x /usr/local/bin/gps-loc

# See https://github.com/allinurl/gwsocket

wget http://tar.gwsocket.io/gwsocket-0.3.tar.gz
tar -xzvf gwsocket-0.3.tar.gz
cd gwsocket-0.3/
./configure
make -j 5
make install
cd ..
rm -rf gwsocket-0.3/ gwsocket-0.3.tar.gz

# Usage example:
#gwsocket -p 7474 --pipein=out  &
#socat - TCP4:localhost:10110 >> out  &
#wsdump -r ws://localhost:7474/



