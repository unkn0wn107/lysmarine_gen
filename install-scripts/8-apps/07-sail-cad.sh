#!/bin/bash -e

if [ "$BBN_KIND" == "LIGHT" ] ; then
  exit 0
fi

apt-get -q -y install sailcut sailcut-doc

