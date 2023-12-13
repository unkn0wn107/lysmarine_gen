#!/bin/bash -e

if [ "$LMARCH" == 'arm64' ]; then
  apt-get -y install openjdk-17-jdk openjdk-17-jdk-headless openjdk-17-jre openjdk-17-jre-headless
fi
