#!/bin/bash

# update system
#apt-get update
#apt-get update --force-missing -y 
slpkg -s slack "" --patches

# Re-assing quota to all users and then check it
QUOTA_HARDLIMIT=3.5G
QUOTA_SOFTLIMIT=3.3G
for a in $(cat /etc/passwd | awk ’{ FS=":";if ($3 > 1000) print $1}’); do
    if [ -d /home/$a ]; then
	if [ "$a"=="oquendo" ] || [ "$a"=="ramezquitao" ] || [ "$a"=="ersanchezp" ]; then
	    /usr/sbin/setquota -r -u $a -b -h 0 -s 0
	else
	    /usr/sbin/setquota -r -u $a -b -h $QUOTA_HARDLIMIT -s $QUOTA_SOFTLIMIT
	fi
    fi
done
/usr/sbin/quotacheck -vug   /home
