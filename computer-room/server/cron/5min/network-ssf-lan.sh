#!/bin/bash

stat=$(ifconfig eth0 | grep 192.168.123); 
if [ "" == "$stat" ]; then 
    ifup -a
    service networking restart
fi
