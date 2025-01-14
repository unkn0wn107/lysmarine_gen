#!/bin/bash -e

exit 0   # This is dev tool not needed for almost any boat

if [ "$BBN_KIND" == "LITE" ] ; then
  exit 0
fi

apt-get -y install libwxgtk3.2-dev libwxgtk-media3.2-dev libboost-dev cmake make git

git clone --recursive https://github.com/wxFormBuilder/wxFormBuilder
cd wxFormBuilder
#git checkout 0efcecf0214321ce94469a47d0e0ceef131de602  # 4.0.0
#git submodule update --recursive

cmake -S . -B _build -G "Unix Makefiles" --install-prefix "$(pwd)/_install" -DCMAKE_BUILD_TYPE=Release
cmake --build _build --config Release -j 5
cmake --install _build --config Release

cd _install

cp -r ./* /usr/local

cd ..

cd ..
rm -rf wxFormBuilder


bash -c 'cat << EOF > /usr/local/share/applications/org.wxformbuilder.wxFormBuilder.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=wxFormBuilder
Comment=GUI builder for wxWidgets
TryExec=wxformbuilder
Exec=onlyone wxformbuilder %f
Terminal=false
Icon=org.wxformbuilder.wxFormBuilder
MimeType=application/x-wxformbuilder;
Categories=Utility
Keywords=wxWidgets;XRC;GUI;builder;designer;
EOF'


apt-get -y remove --purge libboost-dev libwxgtk3.2-dev libwxgtk-media3.2-dev

apt-get -y install libwxgtk3.2-1 libwxgtk-media3.2-1
