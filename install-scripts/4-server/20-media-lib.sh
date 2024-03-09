#!/bin/bash -e

if [ "$BBN_KIND" == "LITE" ] ; then
  exit 0
fi

#apt-get install -y jellyfin

wget -q -O - https://repo.jellyfin.org/files/server/debian/latest-stable/arm64/jellyfin-server_10.8.13-1_arm64.deb > jellyfin-server.deb
wget -q -O - https://repo.jellyfin.org/files/server/debian/latest-stable/arm64/jellyfin-web_10.8.13-1_all.deb > jellyfin-web.deb
wget -q -O - https://repo.jellyfin.org/files/server/debian/latest-stable/arm64/jellyfin_10.8.13-1_all.deb > jellyfin.deb
wget -q -O - https://repo.jellyfin.org/releases/server/debian/versions/jellyfin-ffmpeg/5.1.4-3/jellyfin-ffmpeg5_5.1.4-3-bookworm_arm64.deb > jellyfin-ffmpeg5.deb

dpkg -i jellyfin*.deb
rm -rf jellyfin*.deb

systemctl disable jellyfin
