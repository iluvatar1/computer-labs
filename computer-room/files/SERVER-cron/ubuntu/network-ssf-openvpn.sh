#!/bin/bash

stat=$(ifconfig eth0 | grep 10.88.55); 
if [ "" == "$stat" ]; then 
    ifup -a
    service networking restart
fi
