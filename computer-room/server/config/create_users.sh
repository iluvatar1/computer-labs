#!/bin/bash

FNAME=${1}
if [[ ! -f $FNAME ]]; then
    echo "Error: filename $FNAME does not exists"
    exit 1
fi

while read line
do
    username=$(echo $line | awk '{print $1}')
    password=$(echo $line | awk '{print $2}')
    echo username=$username
    echo password=$password
    # echo "Deleting account $username"
    # userdel $username
    echo Creating account $username
    useradd -d /home/$username -G audio,cdrom,floppy,plugdev,video -m -s /bin/bash $username 
    echo "Changing password for $username to ${password}"
    echo ${username}:${password} | chpasswd
    #echo "Recursive chown ... &"
    #chown -R $username.$username /home/$username &
done < $FNAME

read

echo "Updating nis database"
make -C /var/yp/
service portmap restart
service ypserv  restart
echo "DONE."
