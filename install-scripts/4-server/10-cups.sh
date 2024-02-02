#!/bin/bash -e

apt-get -y -q --no-install-recommends --no-install-suggests install cups

usermod -a -G lpadmin user

