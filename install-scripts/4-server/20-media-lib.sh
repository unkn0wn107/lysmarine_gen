#!/bin/bash -e

if [ "$BBN_KIND" == "LITE" ] ; then
  exit 0
fi

apt-get install -y jellyfin

systemctl disable jellyfin
