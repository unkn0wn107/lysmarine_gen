#!/bin/bash -e

# See: https://github.com/DeskPi-Team/deskpi

cd ~
git clone --depth=1 https://github.com/DeskPi-Team/deskpi.git
cd ~/deskpi/

myArch=$(dpkg --print-architecture)

echo "Note: this software assumes /dev/ttyUSB0 is used for fan control"
echo "      which might be not the case on your system and it can cause"
echo "      weird USB errors and resets."
echo "      Read https://github.com/DeskPi-Team/deskpi/tree/master/drivers"
echo "      If unsure turn off fan control service:"
echo " sudo systemctl disable deskpi"
echo " sudo systemctl stop deskpi"

if [ "arm64" != "$myArch" ] ; then
  chmod +x install.sh
  sudo ./install.sh
else
  chmod +x install-raspios-64bit.sh
  sudo ./install-raspios-64bit.sh
fi
