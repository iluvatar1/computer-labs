#!/bin/bash

#sudo -u oquendo ssh -vv -o ConnectTimeout=10 -o ConnectionAttempts=1 168.176.14.174 -p 22 -l oquendo w &>/dev/null
status=$(netstat -lepn | grep ssh | grep ":22" | grep LISTEN)

#if [[ "$?" != "0" ]]; then
if [[ "" == "$status" ]]; then
    echo "Restarting ssh server"
    service networking stop
    service networking start
    sleep 10
    service ssh stop
    service ssh start
#else 
#    echo
#    echo "ssh connection test successfull"
fi
