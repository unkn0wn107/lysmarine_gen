#!/bin/bash -e

if [ "$BBN_KIND" == "LIGHT" ] ; then
  exit 0
fi

if [ "$LMARCH" == 'arm64' ]; then
  apt-get -y install openjdk-17-jdk openjdk-17-jdk-headless openjdk-17-jre openjdk-17-jre-headless
fi
