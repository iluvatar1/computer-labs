#!/bin/bash

for usernamedir in /home/*; do 
    if [ -d $usernamedir ]; then
	username=$(basename $usernamedir)
	if [ "ftp" != "$username" ] && [ "localuser" != "$username" ] ; then 
	    #echo "Deleting account $username"
	    #userdel $username
	    echo Creating account $username
	    useradd -d /home/$username -G audio,cdrom,floppy,plugdev,video -m -s /bin/bash $username
	    echo "Changing password for $username to ${username}123"
	    echo ${username}:${username}123 | chpasswd 
	    echo "Recursive chown ... &"
	    chown -R $username.$username /home/$username & 
	fi
    fi
done
echo "Updating nis database"
make -C /var/yp/
service portmap restart
service ypserv  restart

echo "DONE."
