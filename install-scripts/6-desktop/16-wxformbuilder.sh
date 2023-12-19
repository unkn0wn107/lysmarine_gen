#!/bin/bash -e

exit 0 # TODO: disabled

apt-get -y install libwxgtk3.2-dev libwxgtk-media3.2-dev libboost-dev meson cmake make git

git clone https://github.com/wxFormBuilder/wxFormBuilder
cd wxFormBuilder
git checkout 0efcecf0214321ce94469a47d0e0ceef131de602  # 4.0.0
git submodule update --recursive

meson _build --prefix "$PWD"/_install --buildtype=release
ninja -C _build -j 4 install

cd _install

mv bin/* /usr/local/bin/
mv share/* /usr/local/share/
mv lib/a*-linux-*/* /usr/local/lib/

cd ..

cd ..
rm -rf wxFormBuilder


bash -c 'cat << EOF > /usr/local/share/applications/wxformbuilder.desktop
[Desktop Entry]
Type=Application
Name=WxFormBuilder
GenericName=WxFormBuilder
Comment=WxFormBuilder
Exec=onlyone wxformbuilder
Terminal=false
Icon=document
Categories=Utility;
EOF'


apt-get -y remove --purge libboost-dev
