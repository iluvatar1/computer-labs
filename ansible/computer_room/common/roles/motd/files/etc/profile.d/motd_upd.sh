#!/bin/bash

cat /etc/slackware-version
uname -s -r

#if [[ "root" == "$(whoami)" ]]; then
#    exit 0
#fi

echo "En este momento se encuentran activos los siguientes cientes:"
cat /home/clients_status.txt

echo ""
echo "Por favor no ejecutar tareas en el servidor principal"
echo ""
