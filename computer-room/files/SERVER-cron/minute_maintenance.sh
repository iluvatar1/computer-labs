#!/bin/bash

echo "Testing network interfaces ..."
date +%c
stat=$(/sbin/ifconfig | grep 168.176);
if [ "" == "$stat" ]; then
    echo "Restarting eth0 ..."
    #    /sbin/ifup eth1
    #/sbin/ifconfig eth0 down
    #/sbin/ifconfig eth0 up
    /etc/rc.d/rc.inet1 eth0_restart
fi
stat=$(/sbin/ifconfig | grep 192.168);
if [ x"" == x"$stat" ]; then
    echo "Restarting eth1 ..."
    #/sbin/ifconfig eth1 down
    #/sbin/ifconfig eth1 up
    /etc/rc.d/rc.inet1 eth1_restart
#    /sbin/ifdown eth1
#    /sbin/ifup eth1
#    /etc/init.d/networking stop
#    /etc/init.d/networking start
fi

# wake on lan
echo "Wakeonlan"
if [ ! -f /root/MACS ]; then 
    wakeonlan -i 192.168.10.255 -f /root/MACS
else
    echo "File does not exists: /root/MACS"
fi

echo "rebuild nis database"
make -C /var/yp

echo "Advertising correct speed for eth1"
ethtool -s eth1 advertise 0x010
