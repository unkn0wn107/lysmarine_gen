#!/bin/bash -e

apt-get install -y -q yad ssh-askpass-gnome

install -d '/usr/local/share/applications'

if [ "$BBN_KIND" == "LITE" ] ; then
  install -m 755 "$FILE_FOLDER"/servicedialog-light.sh "/usr/local/bin/servicedialog"
else
  install -m 755 "$FILE_FOLDER"/servicedialog.sh "/usr/local/bin/servicedialog"
fi

install -m 644 "$FILE_FOLDER"/servicedialog.desktop "/usr/local/share/applications/"
