#!/bin/bash -e



if [ "$BBN_KIND" == "LITE" ] ; then
  exit 0
fi

bash -c 'cat << EOF > /usr/local/share/applications/ocearo-ui.desktop
[Desktop Entry]
Type=Application
Name=Ocearo-UI
GenericName=Ocearo-UI
Comment=Ocearo-UI 3D
Exec=gnome-www-browser http://localhost:3000/ocearo-ui
# Read: https://github.com/laborima/ocearo-ui
Terminal=false
Icon=gnome-globe
Categories=Navigation
EOF'

exit 0 # Now it is installed as SignalK plugin

git clone --depth=1 https://github.com/laborima/ocearo-ui
cd ocearo-ui
#npm install
npm install tailwindcss @tailwindcss/postcss next 
export MAKEFLAGS='-j 8'
export NODE_ENV=production
npm run build
cp -rf ./out/* ./public/; rm -rf ./out
rm -rf ./.git
cd ..
mv ./ocearo-ui /home/signalk/.signalk/node_modules/
chown -R signalk:signalk /home/signalk/.signalk/node_modules/ocearo-ui

