#!/bin/bash -e

if [ "$BBN_KIND" == "LIGHT" ] ; then
  exit 0
fi

apt-get -y -q install libcanberra-gtk-module gnome-calendar
