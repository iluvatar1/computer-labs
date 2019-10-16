#!/bin/bash

# check ip in lan
FLAG=$(ifconfig | grep 192.168.10)
if [[ "" == "$FLAG" ]]; then
    echo "No good ip found. Restarting network."
    /etc/rc.d/rc.inet1 restart 
fi

# check that NFS-home is mounted
FLAG=$(mount | grep -i home | grep nfs)
if [[ "" == "$FLAG" ]]; then
    echo "Home is not mounted. Mounting again."
    /etc/rc.d/rc.nfsd restart 
    mount -a 
fi

# check nis
FLAG=$(ypcat passwd | grep home)
if [[ "" == "$FLAG" ]]; then
    echo "NIS has problems. Restarting NIS."
    /etc/rc.d/rc.yp restart 
fi
