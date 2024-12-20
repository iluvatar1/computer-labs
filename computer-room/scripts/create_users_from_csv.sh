#!/bin/bash

echo "This script creates users according to a file with a list of usernames, passwords, fullnames"
echo "The file must present the info as:"
echo "username,password,fullname"
echo "You can specify and EXPIRE_DATE as env var"
echo "FNAME=${1}"
echo "EXPIRE_DATE=${EXPIRE_DATE}"
sleep 3

FNAME="${1}"
EXPIRATION_DATE="${EXPIRATION_DATE:-}"
INACTIVE_DAYS="${INACTIVE_DAYS:-90}"

if [ ! -f "$FNAME" ]; then
    echo "Error: filename $FNAME does not exists"
    exit 1
fi

create_accounts () {
    fname="$1"
    expire_date="${2:-}"
    groups='audio,cdrom,floppy,plugdev,video,netdev,lp,scanner,sshgroup'
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
	    if [[ ! -z "$EXPIRE_DATE" ]] ; then
		echo "Changing the expire date ..."
		chage -E $EXPIRE_DATE -I $INACTIVE_DAYS $username
	    fi
            continue
	fi
	# echo "Deleting account $username"
	# userdel $username
	echo "Creating account->${username}"
	useradd -d /home/${username} -G "$groups" -m -s /bin/bash ${username} -c "${comment}" -e "$expire_date" || exit 1
	echo "Changing password to ${password}"
	#echo ${username}:${password} | chpasswd
 	usermod --password $(echo ${password} | openssl passwd -1 -stdin) ${username}
	#echo "make the password expire to force changing it on first login"
	#chage -d0 ${username}
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
