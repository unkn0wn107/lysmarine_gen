#!/bin/bash -e

apt-get clean

apt-get -y -q install geographiclib-tools libqt5charts5 libqt5multimediawidgets5 libqt5script5 

wget http://ppa.launchpad.net/stellarium/stellarium-releases/ubuntu/pool/main/s/stellarium/stellarium_1.0-upstream1.0~ubuntu20.04.1_arm64.deb
wget http://ppa.launchpad.net/stellarium/stellarium-releases/ubuntu/pool/main/s/stellarium/stellarium-data_1.0-upstream1.0~ubuntu20.04.1_all.deb

dpkg --ignore-depends=qtbase-abi-5-12-8 -i stellarium*.deb
rm -f stellarium*.deb

install -d -o 1000 -g 1000 -m 0755 "/home/user/.stellarium"
install -v -o 1000 -g 1000 -m 0644 $FILE_FOLDER/stellarium-config.ini "/home/user/.stellarium/config.ini"

install -v -m 0644 $FILE_FOLDER/stellarium.desktop /usr/share/applications/
install -v -m 0755 $FILE_FOLDER/stellarium-augmented.sh /usr/local/bin/stellarium-augmented

geographiclib-get-magnetic all

apt-get clean

apt-mark hold stellarium stellarium-data
