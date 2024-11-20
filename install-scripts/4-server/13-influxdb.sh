#!/bin/bash -e

apt-get clean

if [ "$BBN_KIND" == "LITE" ] ; then
  exit 0
fi

groupadd -g 988 influxdb
useradd -u 994 -r influxdb -d /var/lib/influxdb
usermod -a -G influxdb influxdb

apt-get -y -q install influxdb chronograf kapacitor telegraf

systemctl unmask influxdb
systemctl disable influxdb

systemctl disable chronograf
systemctl disable kapacitor
systemctl disable telegraf
