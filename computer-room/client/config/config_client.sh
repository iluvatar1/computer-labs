#!/bin/bash

###############
## TODO
# - Ubuntu: Check and make idempotent
# Test
###############

source ../../util_functions.sh
source ../../config.sh

TARGET="client"

echo "Configuring $TARGET ..."

# global vars
BDIR=$PWD
FDIR=$1
LINUX="SLACKWARE"

# Network manager
#echo "Removing permissions for network manager ..."
#chmod -x /etc/rc.d/rc.wireless
#chmod -x /etc/rc.d/rc.networkmanager
echo "Creating Network Manager hook"
if [ ! -f "/etc/NetworkManager/dispatcher.d/90networkmanagerhook.sh" ]; then
    cp $FDIR/CLIENT-90networkmanagerhook.sh /etc/NetworkManager/dispatcher.d/90networkmanagerhook.sh
    chmod +x /etc/rc.d/rc.networkmanager
    bash /etc/rc.d/rc.networkmanager restart
    /etc/rc.d/rc.inet2 restart
else
    echo "Already configured."
fi
echo "DONE: Configuring  network manager"


# ntp server
echo "Configuring ntp "
if [ "$LINUX" == "SLACKWARE" ]; then
    if [ x"" == x"$(grep $SERVERIP /etc/ntp.conf)" ]; then
	bfile=/etc/ntp.conf
	backup_file $bfile
	cp -f $FDIR/CLIENT-ntp-client.conf $bfile
	chmod +x /etc/rc.d/rc.ntpd
	/etc/rc.d/rc.ntpd restart
    else
	echo "    -> already configured"
    fi
else
    echo "UBUNTU NOT CONFIGURED"
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
    cp -f $FDIR/CLIENT-nsswitch.conf $bfile
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
	if [ x"" == x"$(grep 'YP_CLIENT_ENABLE=1' /etc/rc.d/rc.yp) 2>/dev/null" ]; then 
	    chmod +x /etc/rc.d/rc.yp
	    chmod +x /etc/rc.d/rc.nfsd
	    backup_file /etc/rc.d/rc.yp
	    sed -i.bck 's/YP_CLIENT_ENABLE=.*/YP_CLIENT_ENABLE=1/ ; s/YP_SERVER_ENABLE=.*/YP_SERVER_ENABLE=0/ ;' /etc/rc.d/rc.yp
	fi
	/etc/rc.d/rc.yp restart    
	/etc/rc.d/rc.nfsd restart
	/etc/rc.d/rc.inet2 restart
    elif [ "$LINUX" == "UBUNTU" ]; then
	service portmap restart
	service ypserv restart
    fi
    rpcinfo -p localhost
else
    echo "    -> already configured."
fi
echo "DONE: Configuring nis "


# # config lightm options
# if [ "$LINUX" == "UBUNTU" ]; then 
#     echo "Allowing direct login on lightdm"
#     bfile="/etc/lightdm/lightdm.conf"
#     backup_file $bfile
#     echo "greeter-show-manual-login=true" >> $bfile
#     echo "greeter-hide-users=true" >> $bfile
#     echo "greeter-allow-guest=false" >> $bfile
#     echo "allow-guest=false" >> $bfile
# fi

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

# default xsession : xfce
echo "Configuring xsession in case it is not configured ..."
bname=/etc/skel/.xsession
if [ ! -f $bname ]; then 
    cp $FDIR/CLIENT-xsession $bname
fi
bname=/etc/skel/.xinitrc
if [ ! -f $bname ]; then 
    cp $FDIR/CLIENT-xinitrc $bname
fi

# latam keyboard
echo "Configuring default X windows keyboard to be latam ..."
bfile=/etc/X11/xorg.conf.d/90-keyboard-layout.conf
if [ x"" == x"$(grep la-latin1 $bfile 2>/dev/null)" ]; then 
    if [ -f $bfile ]; then
	backup_file $bfile
    fi
    cat<<EOF > $bfile
Section "InputClass"
        Identifier "keyboard-all"
        MatchIsKeyboard "on"
        MatchDevicePath "/dev/input/event*"
        Driver "evdev"
        Option "XkbLayout" "latam"
        #Option "XkbVariant" ""
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF
else
    echo "    -> already configured"
fi


echo "Configuring cronjob check status"
if [ ! -f /etc/cron.d/check_status_cronjob ] || [ ! -f /root/scripts/check_status.sh ]; then
    mkdir -p /root/scripts
    cp -f $FDIR/CLIENT-cron/check_status.sh /root/scripts/
    cp -f $FDIR/CLIENT-cron/check_status_cronjob /etc/cron.d/
else
    echo "    -> already configured ."
fi

echo "Copying server public key  to configure passwordless access for root"
mkdir -p /root/.ssh &>/dev/null
if [ x"" == x"$(grep serversalafis /root/.ssh/authorized_keys 2>/dev/null)" ]; then
    cat $FDIR/CLIENT-server_id_rsa.pub >> /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    chmod 640 /root/.ssh/authorized_keys
else
    echo "    -> already configured"
fi

echo "Removing permissions to reboot/halt system"
chmod o-x /sbin/shutdown 
chmod o-x /sbin/halt
fname=disallow-power-options.rules
if [ ! -f /etc/polkit-1/rules.d/$fname ]; then
    cp $FDIR/CLIENT-$fname /etc/polkit-1/rules.d/
fi

echo "#####################################"
echo "Done."
