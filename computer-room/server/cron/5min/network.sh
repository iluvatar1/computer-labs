#!/bin/bash

stat=$(/sbin/ifconfig eth0 | grep 168.176); 
if [ "" == "$stat" ]; then 
#    /sbin/ifup eth1
    /sbin/ifconfig eth0 down
    /sbin/ifconfig eth0 up
fi

stat=$(/sbin/ifconfig eth1 | grep 192.168); 
if [ "" == "$stat" ]; then 
    /sbin/ifconfig eth1 down
    /sbin/ifconfig eth1 up
#    /sbin/ifdown eth1
#    /sbin/ifup eth1
#    /etc/init.d/networking stop
#    /etc/init.d/networking start
fi
