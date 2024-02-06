#!/bin/bash -e

cd /home/user
git clone --depth=1 https://github.com/peterantypas/maiana

bash -c 'cat << EOF > /usr/local/share/applications/maiana-util.desktop
[Desktop Entry]
Type=Application
Name=Maiana AIS Util
GenericName=Maiana AIS Util
Comment=Maiana AIS Util
Exec=python3 /home/user/maiana/latest/Apps/maiana-update/maiana.py
Terminal=false
Icon=radio
Categories=X-GNOME-Utilities;
Keywords=HamRadio;Radio
EOF'

rm -rf /home/user/maiana/.git
rm -rf /home/user/maiana/images
