#!/bin/bash -e

if [ "$BBN_KIND" == "LIGHT" ] ; then
  exit 0
fi

apt-get -y install libqt5webenginecore5 libqt5webenginewidgets5 zim-tools kiwix
