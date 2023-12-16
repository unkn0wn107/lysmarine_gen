#!/bin/bash -e

bash -c 'cat << EOF > /usr/local/share/applications/boatsetter.desktop
[Desktop Entry]
Type=Application
Name=BoatSetter
GenericName=BoatSetter
Comment=BoatSetter
Exec=gnome-www-browser https://www.boatsetter.com/
Terminal=false
Icon=gnome-globe
Categories=WWW;Internet
EOF'
