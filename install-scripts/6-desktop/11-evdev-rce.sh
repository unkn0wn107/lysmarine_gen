#!/bin/bash -e

if [ "$LMARCH" == 'arm64' ]; then
  wget https://github.com/bareboat-necessities/lysmarine_gen/releases/download/vTest/evdev-rce_1.0.0.1_arm64.deb -O evdev-rce.deb
fi

dpkg -i evdev-rce.deb && rm -f evdev-rce.deb

echo 'uinput' | tee -a /etc/modules

install -o 1000 -g 1000 -d "/home/user/.config"
install -o 1000 -g 1000 -d "/home/user/.config/autostart"
