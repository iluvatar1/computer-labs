#!/bin/bash

# update system
#apt-get update
#apt-get update --force-missing -y 
#slpkg -s slack "" --patches

# Re-assing quota to all users and then check it
QUOTA_HARDLIMIT=5.5G
QUOTA_SOFTLIMIT=6.0G
for a in $(cat /etc/passwd | awk '{ FS=":";if ($3 > 1000) print $1}'); do
    if [ -d /home/$a ]; then
	echo $a
	if [[ "$a" == "oquendo" ]] || [[ "$a" == "ramezquitao" ]] || [[ "$a" == "ersanchezp" ]]; then
	    /usr/sbin/setquota -b -u $a 0 0
	else
	    echo /usr/sbin/setquota -b -u $a $QUOTA_HARDLIMIT $QUOTA_SOFTLIMIT
	    echo 2
	fi
    fi
done
/usr/sbin/quotacheck -vug /home
