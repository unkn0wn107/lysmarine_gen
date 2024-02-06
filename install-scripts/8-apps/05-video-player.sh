#!/bin/bash -e

if [ "$BBN_KIND" == "LITE" ] ; then
  exit 0
fi

apt-get clean

apt-get -y -q install vlc webcamoid vokoscreen # totem

install -o 1000 -g 1000 -d /home/user/.config/Webcamoid
install -o 1000 -g 1000 -v "$FILE_FOLDER"/Webcamoid.conf /home/user/.config/Webcamoid/

