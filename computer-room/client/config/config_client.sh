#!/bin/bash

###############
## TODO
# - Ubuntu: Check and make idempotent
# Test
###############

function usage()
{
    echo "USAGE: "
    echo "config_server.sh DIR LINUX_FLAVOR"
    echo "DIR          : Where to find the model config files"
    echo "LINUX_FLAVOR : UBUNTU or SLACKWARE , in capital"
}

# check args
if [ "$#" -ne "2" ]; then usage; exit 1 ; fi
if [ ! -d "$1" ]; then echo "Dir does not exist : $1"; usage; exit 1 ; fi
if [  "$2" != "UBUNTU" ] && [  "$2" != "SLACKWARE" ]; then usage; exit 1 ; fi


echo "Configuring client ..."
# global vars
BDIR=$PWD
FDIR=$1
LINUX=$2

SERVERIP=192.168.10.1

# global functions
function backup_file()
{
    if [ -e "$1" ]; then
        cp -v "$1" "$1".orig-$(date +%F--%H-%M-%S)
    fi
}

function copy_config()
{
    mfile="$1"
    bfile="$2"
    backup_file "$bfile"
    cp -vf "$mfile" "$bfile"
}


# network interfaces
# slackware already configured to use DHCP
if [ "$LINUX" == "UBUNTU" ]; then 
    echo "Configuring network interface"
    bfile=/etc/network/interfaces
    backup_file $bfile
    cat <<EOF > $bfile
auto eth0
iface eth0 inet dhcp
dns-nameservers ${SERVERIP}
EOF
    /etc/init.d/networking restart
    echo "DONE: Configuring network interface in UBUNTU"
fi

echo "Removing permissions for network manager ..."
chmod -x /etc/rc.d/rc.wireless
chmod -x /etc/rc.d/rc.networkmanager

echo "Adding dhcp for eth1"
sed -i.bck 's/USE_DHCP\[1\]=""/USE_DHCP\[1\]="yes"/' /etc/rc.d/rc.inet1.conf


# Mirror configuration
echo "Configuring packages mirrors"
if [ "$LINUX" == "SLACKWARE" ]; then
    bfile=/etc/slackpkg/mirrors
    if [ x"" == x"$(grep tds $bfile)" ]; then 
	backup_file $bfile
	cat <<EOF > $bfile
http://slackware.mirrors.tds.net/pub/slackware/slackware-14.2/
EOF
	slackpkg update
    else
	echo "    -> Mirror already configured."
    fi
elif [ "$LINUX" == "UBUNTU" ]; then
    bfile=/etc/apt/sources.list
    backup_file $bfile
    cat <<EOF > $bfile
deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse
#deb http://168.176.34.158/ubuntu/ precise main multiverse restricted universe
#deb http://168.176.34.158/ubuntu/ precise-updates main multiverse restricted universe
EOF
    apt-get update
    apt-get -y install emacs
fi
echo "DONE: Configuring packages mirrors"


# ssh server
echo "Configuring ssh "
if [ "$LINUX" == "SLACKWARE" ]; then
    chmod +x /etc/rc.d/rc.sshd
    /etc/rc.d/rc.sshd start
elif [ "$LINUX" == "UBUNTU" ]; then
# apt-get install openssh-client openssh-server
    mv /etc/ssh/ssh_host_* ./
    dpkg-reconfigure openssh-server
    service ssh restart
fi
echo "DONE: Configuring ssh"


# ntp server
echo "Configuring ntp "
if [ "$LINUX" == "SLACKWARE" ]; then
    if [ x"" == x"$(grep $SERVERIP /etc/ntp.conf)" ]; then
	bfile=/etc/ntp.conf
	backup_file $bfile
	cp -f $FDIR/ntp-client.conf $bfile
	chmod +x /etc/rc.d/rc.ntpd
	/etc/rc.d/rc.ntpd restart
    else
	echo "    -> already configured"
    fi
fi
echo "DONE: Configuring  ntp"


# nfs
echo "Configuring nfs for home "
bfile="/etc/fstab"
if [ x"" == x"$(grep ${SERVERIP} $bfile 2> /dev/null)" ]; then
    backup_file $bfile
    echo "# NEW NEW NEW NFS stuff " >> $bfile
    echo "${SERVERIP}:/home     /home   nfs     rw,hard,intr,usrquota  0   0" >> $bfile
else
    echo "    -> already configured"
fi
if [ "$LINUX" == "UBUNTU" ]; then
    bfile="/etc/modules"
    backup_file $bfile
    echo "nfs" >> $bfile
fi
#mount -a
echo "DONE: Configuring nfs"

# nis
NISDOMAIN=salafisnis
echo "Configuring nis "
if [ x"" == x"$(grep ${NISDOMAIN} /etc/defaultdomain 2> /dev/null)" ]; then
    bfile="/etc/defaultdomain"
    backup_file $bfile
    echo ${NISDOMAIN} > $bfile  
    bfile="/etc/yp.conf"
    backup_file $bfile
    echo "ypserver ${SERVERIP}" > $bfile
    bfile=/etc/nsswitch.conf
    backup_file $bfile
    cp -f $FDIR/client-nsswitch.conf $bfile
    bfile="/etc/passwd"
    backup_file $bfile
    echo +:::::: >> $bfile
    bfile="/etc/shadow"
    backup_file $bfile
    echo +:::::::: >> $bfile
    bfile="/etc/group"
    backup_file $bfile
    echo +::: >> $bfile
    if [ "$LINUX" == "SLACKWARE" ]; then
	chmod +x /etc/rc.d/rc.yp
	chmod +x /etc/rc.d/rc.nfsd
	backup_file /etc/rc.d/rc.yp
	sed -i.bck 's/YP_CLIENT_ENABLE=.*/YP_CLIENT_ENABLE=1/ ; s/YP_SERVER_ENABLE=.*/YP_SERVER_ENABLE=0/ ;' /etc/rc.d/rc.yp
	#/etc/rc.d/rc.yp restart    
	#/etc/rc.d/rc.nfsd restart
	#/etc/rc.d/rc.inet2 restart
    elif [ "$LINUX" == "UBUNTU" ]; then
	service portmap restart
	service ypserv restart
    fi
    rpcinfo -p localhost
else
    echo "    -> already configured."
fi
echo "DONE: Configuring nis "


# config lightm options
if [ "$LINUX" == "UBUNTU" ]; then 
    echo "Allowing direct login on lightdm"
    bfile="/etc/lightdm/lightdm.conf"
    backup_file $bfile
    echo "greeter-show-manual-login=true" >> $bfile
    echo "greeter-hide-users=true" >> $bfile
    echo "greeter-allow-guest=false" >> $bfile
    echo "allow-guest=false" >> $bfile
fi

# Configure root internet access
bname="~/.bashrc"
if [ x"" == "$(grep https_proxy ${bname} 2>/dev/null)" ]; then
    echo 'export PROXY="fisicasop_fcbog:s4l4fis219@proxyapp.unal.edu.co:8080/" ' >> $bname
    echo 'export http_proxy="http://$PROXY" ' >> $bname
    echo 'export https_proxy="https://$PROXY" ' >> $bname
    echo 'export ftp_proxy="ftp://$PROXY" ' >> $bname
    echo 'export RSYNC_PROXY="$PROXY" ' >> $bname
else
    echo "Root proxy already configured."
fi

# Configuring lilo
echo "Configuring lilo delay time to 5 seconds ..."
bname="/etc/lilo.conf"
if [ x"" == x"$(grep -re 'timeout.*50' 2>/dev/null $bname)" ]; then
    backup_file $bname
    sed -i.bck 's/timeout = 1200/timeout = 50/' $bname
    lilo
else
    echo "   -> already configured."
fi

# default xsession : xfce
echo "Configuring xsession in case it is not configured ..."
bname=/etc/skel/.xsession
if [ ! -f $bname ]; then 
    cp $FDIR/xsession $bname
fi
bname=/etc/skel/.xinitrc
if [ ! -f $bname ]; then 
    cp $FDIR/xinitrc $bname
fi

# la latin keyboard
echo "Configuring default X windows keyboard to be la-latin1 ..."
bfile=/etc/X11/xorg.conf.d/90-keyboard-layout.conf
if [ -f $bfile ]; then
    backup_file $bfile
fi
cat <<EOF > $bfile
Section "InputClass"
        Identifier "keyboard-all"
        MatchIsKeyboard "on"
        MatchDevicePath "/dev/input/event*"
        Driver "evdev"
        Option "XkbLayout" "la-latin1"
        #Option "XkbVariant" ""
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF

echo "Configuring cronjob check status"
if [ ! -f /etc/cron.d/check_status_cronjob ] || [ ! -f /root/scripts/check_status.sh ]; then
    mkdir -p /root/scripts
    cp -f $FDIR/cron/check_status.sh /root/scripts/
    cp -f $FDIR/cron/check_status_cronjob /etc/cron.d/
else
    echo "    -> already configured ."
fi

echo "Copying server public key  to configure passwordless access for root"
mkdir -p /root/.ssh &>/dev/null
if [ x"" != x"$(grep serversalafis /root/.ssh/known_hosts 2>/dev/null)" ]; then
    cat $FDIR/server_id_rsa.pub >> /root/.ssh/known_hosts
else
    echo "    -> already configured"
fi

echo "#####################################"
echo "Done."
