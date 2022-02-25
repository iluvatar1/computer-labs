#!/bin/bash

# update system
#apt-get update
#apt-get update --force-missing -y 
slpkg -s slack "" --patches


# Re-assing quota to all users and then check it
QUOTA_SOFTLIMIT=5.5G
QUOTA_HARDLIMIT=6.0G
INODES=1000000 # like number of files
for a in $(cat /etc/passwd | awk ’{ FS=":";if ($3 > 1000) print $1}’); do
    if [ -d /home/$a ]; then
        if [[ "$a" == "root" ]] || [[ "$a" == "oquendo" ]] || [[ "$a" == "ramezquitao" ]] || [[ "$a" == "ersanchezp" ]]; then
            continue
        else
            /usr/sbin/setquota -u -F vfsv1 $a  $QUOTA_SOFTLIMIT $QUOTA_HARDLIMIT $INODES $INODES /home
        fi
    fi
done
/usr/sbin/quotacheck -vug   /homew
