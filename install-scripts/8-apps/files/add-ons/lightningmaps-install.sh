#!/bin/bash -e

bash -c 'cat << EOF > /usr/local/share/applications/lightningmaps.desktop
[Desktop Entry]
Type=Application
Name=Lightning Maps
GenericName=Lightning Maps
Comment=Lightning Maps
Exec=gnome-www-browser https://www.lightningmaps.org/
Terminal=false
Icon=weather-storm
Categories=Internet
EOF'
