#!/bin/bash

# date +%c

# echo "Testing network interfaces ..."
# stat=$(/sbin/ifconfig | grep 168.176.35.111);
# if [ "" == "$stat" ]; then
#     echo "Restarting eth0 ..."
#     #    /sbin/ifup eth1
#     #/sbin/ifconfig eth0 down
#     #/sbin/ifconfig eth0 up
#     #/etc/rc.d/rc.inet1 eth0_restart

#     # sometimes is usefull to flush the cache, but it takes around 10 secs
#     # ip addr flush dev eth0
#     dhcpcd -k
#     pkill dhclient
#     sleep 1
#     /etc/rc.d/rc.inet1 eth0_restart
#     #/sbin/dhclient eth0
# fi
# stat=$(/sbin/ifconfig | grep 192.168.10.1);
# if [ x"" == x"$stat" ]; then
#     echo "Restarting eth1 ..."
#     #/sbin/ifconfig eth1 down
#     #/sbin/ifconfig eth1 up
#     /etc/rc.d/rc.inet1 eth1_restart
# #    /sbin/ifdown eth1
# #    /sbin/ifup eth1
# #    /etc/init.d/networking stop
# #    /etc/init.d/networking start
# fi

# wake on lan
echo "Wakeonlan"
if [ -f /root/MACS ] ; then
    #wol -i 192.168.10.255 -f /root/MACS
    #wol -f /root/MACS
    for a in $(cat /root/MACS); do
        wol -i 192.168.10.255  -p 9 -v $a;
    done
else
    echo "File does not exists: /root/MACS"
fi

echo "rebuild nis database"
make -C /var/yp

#echo "Advertising correct speed for eth1"
#ethtool -s eth1 advertise 0x010
