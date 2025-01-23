#!/bin/bash

isEnabled () {
   res="$(systemctl is-enabled $1)"
   if [[ $res == "enabled" ]]; then
      echo "TRUE $1"
   else 
      echo "FALSE $1"
   fi
}

takeAction1 () {
  if echo "$1" | grep -q "$2"; then
    echo "=== enable $2 ==="
    sudo -A systemctl enable $2
    sudo -A systemctl start $2
  else
    echo "=== disable $2 ==="
    sudo -A systemctl disable $2
    sudo -A systemctl stop $2
  fi
}

takeAction2 () {
  if echo "$1" | grep -q "$2"; then
    echo "=== enable $2 ==="
    sudo -A systemctl enable $2
    sudo -A systemctl daemon-reexec
  else
    echo "=== disable $2 ==="
    sudo -A systemctl disable $2
    sudo -A systemctl daemon-reexec
  fi
}

takeAction3 () {
  if echo "$1" | grep -q "$2"; then
    echo "=== enable $2 ==="
    sudo -A systemctl enable $2
    sudo -A systemctl start $2
    sudo -A systemctl daemon-reload
  else
    echo "=== disable $2 ==="
    sudo -A systemctl disable $2
    sudo -A systemctl stop $2
    sudo -A systemctl daemon-reload
  fi
}

## List services and their status
rows="\
$(isEnabled NetworkManager) \
$(isEnabled ssh) \
$(isEnabled kplex) \
$(isEnabled pypilot@pypilot.service) \
$(isEnabled pypilot_web) \
$(isEnabled rtl-ais) \
$(isEnabled signalk) \
$(isEnabled vncserver-x11-serviced) \
$(isEnabled avnav) \
$(isEnabled avnavupdater) \
$(isEnabled mopidy) \
$(isEnabled motioneye) \
$(isEnabled pigpiod) \
"

## Dialog
save=$(
  yad --list \
  --height=400 \
  --title "Service Dialog" \
  --text="BBN OS has multiple services available. Enable and disable them based on what you need." \
  --column="Enable" \
  --column="Service" \
  --checklist \
  $rows
)

ret=$?
## Quit if cancel or close button has been pressed
[[ $ret -ne 0 ]] && exit 0

export SUDO_ASKPASS="/usr/bin/ssh-askpass"

{
  echo 10; takeAction1 "$save" NetworkManager
  echo 30; takeAction1 "$save" ssh
  echo 40; takeAction1 "$save" kplex
  echo 45; takeAction1 "$save" pypilot@pypilot.service
  echo 50; takeAction1 "$save" pypilot_web
  echo 55; takeAction1 "$save" rtl-ais
  echo 60; takeAction1 "$save" signalk
  echo 65; takeAction1 "$save" vncserver-x11-serviced
  echo 75; takeAction2 "$save" avnav
  echo 80; takeAction2 "$save" avnavupdater
  echo 85; takeAction3 "$save" mopidy
  echo 90; takeAction1 "$save" motioneye
  echo 95; takeAction1 "$save" pigpiod
} | yad --progress --title "Service Dialog" --text="Service reconfiguration" --auto-close

