#!/bin/bash

# update system
#apt-get update
#apt-get update --force-missing -y 
#slpkg -s slack "" --patches

# Re-assing quota to all users and then check it
QUOTA_SOFTLIMIT=5120000
QUOTA_HARDLIMIT=5632000
for a in $(cat /etc/passwd | awk '{ FS=":";if ($3 > 1000) print $1}'); do
    if [ -d /home/$a ]; then
	    echo $a
	    if [[ "$a" == "oquendo" ]] || [[ "$a" == "ramezquitao" ]] || [[ "$a" == "ersanchezp" ]] || [[ "$a" == "cesandovalu" ]]; then
            /usr/sbin/setquota -u $a 0 0  0 0 /home
	    else
            /usr/sbin/setquota -u $a 5120000 5632000  0 0 /home
	    fi
    fi
done
/usr/sbin/quotacheck -vug /home
