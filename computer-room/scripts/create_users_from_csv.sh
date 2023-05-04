#!/bin/bash

echo "This script creates users according to a file with a list of usernames, passwords, fullnames"
echo "The file must present the info as:"
echo "username,password,fullname"
echo "You can specify and EXPIRE_DATE as env var"
echo "FNAME=${1}"
echo "EXPIRE_DATE=${EXPIRE_DATE}"
sleep 3

FNAME="${1}"
EXPIRE_DATE="${EXPIRE_DATE:-}"

if [ ! -f "$FNAME" ]; then
    echo "Error: filename $FNAME does not exists"
    exit 1
fi

create_accounts () {
    fname="$1"
    expire_date="${2:-}"
    echo "Creating accounts from file: $FNAME"
    echo "Format should be: username,password,fullname"
    echo "EXPIRE_DATE=${expire_date}"
    sleep 3
    GROUPS="audio,cdrom,floppy,plugdev,video,netdev,lp,scanner,sshgroup"
    while IFS=',' read -r username password fullname
    do
	echo "#############"
	echo "username=${username}"
	echo "password=${password}"
	echo "fullname=${fullname}"
	if [[ -z "${username}" ]]; then echo "ERROR: no username"; exit 1; fi
	if [[ -z "${password}" ]]; then echo "ERROR: no password"; exit 1; fi
	if [[ -d /home/$username ]]; then
            echo "Account already exists. Skipping creation."
	    echo
            continue
	fi
	# echo "Deleting account $username"
	# userdel $username
	echo "Creating account->${username}"
	useradd -d /home/${username} -G "$GROUPS" -m -s /bin/bash ${username} -c "${comment}" -e "$expire_date" || exit 1
	echo "Changing password to ${password}"
	#echo ${username}:${password} | chpasswd
	usermod --password $(echo ${password} | openssl passwd -1 -stdin) ${username}
	echo "make the password expire to force changing it on first login"
	chage -d0 ${username}
	##echo "Recursive chown ... &"
	##chown -R $username.$username /home/$username &
	#read
	echo ""
    done < "$fname"
}

update_databases() {
    echo "Updating nis database"
    make -C /var/yp/
    #service portmap restart
    #service ypserv  restart
    /etc/rc.d/rc.inet2 restart
}


################## main #####################
create_accounts $FNAME $EXPIRE_DATE
update_databases
echo "DONE."
