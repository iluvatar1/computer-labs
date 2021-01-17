#!/usr/bin/env bash
#set -euo pipefail

echo "-> Configuring time zone in xfce4"
if [ x""==x"$(grep -re Bogota $HOME/.config/xfce4)"  ]; then
    eval `dbus-launch --sh-syntax`
    xfconf-query -c xfce4-panel -p "/plugins/plugin-12/timezone" --create -t string -s "America/Bogota"
else
    echo "Already configured"
fi
