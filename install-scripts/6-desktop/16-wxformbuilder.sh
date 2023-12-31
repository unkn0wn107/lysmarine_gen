#!/bin/bash -e

if [ "$BBN_KIND" == "LITE" ] ; then
  exit 0
fi

apt-get -y install libwxgtk3.2-dev libwxgtk-media3.2-dev libboost-dev cmake make git

git clone --recursive https://github.com/wxFormBuilder/wxFormBuilder
cd wxFormBuilder
#git checkout 0efcecf0214321ce94469a47d0e0ceef131de602  # 4.0.0
#git submodule update --recursive

cmake -S . -B _build -G "Unix Makefiles" --install-prefix "$PWD/_install" -DCMAKE_BUILD_TYPE=Release
cmake --build _build --config Release -j 4
#cmake --install _build --config Release

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
