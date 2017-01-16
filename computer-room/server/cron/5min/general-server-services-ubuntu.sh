#!/bin/bash
PATH="/usr/sbin/:/sbin/:$PATH"

SERVICES="arno-iptables-firewall dnsmasq ypserv portmap nfs-kernel-server"

for a in $SERVICES ; do
    echo "Restarting $a"
    /usr/sbin/service $a stop
    /usr/sbin/service $a start
done

#echo "#####################################"
#echo "Done."
