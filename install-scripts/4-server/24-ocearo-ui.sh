#!/bin/bash -e

if [ "$BBN_KIND" == "LITE" ] ; then
  exit 0
fi

pushd /home/signalk/.signalk
  su signalk --shell=/bin/bash -c " set -e; \
  cd node_modules;
  git clone --depth=1 https://github.com/laborima/ocearo-ui; \
  cd ocearo-ui; \
  pnpm install; \
  export MAKEFLAGS='-j 8'; \
  export NODE_ENV=production; \
  pnpm run build; \
  cp -r ./out/* public/; rm -rf ./out; \
  rm -rf ./.git; cd ../.."
popd

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
