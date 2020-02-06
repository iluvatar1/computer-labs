#!/bin/bash

# NOTE: The original base file is in the config_computer_room.org file

SCRIPTS_DIR=$HOME/repos/computer-labs/computer-room/scripts

if [ ! -f params.conf ]; then 
    echo "ERROR: Config file not found -> params.conf"
    exit 1
fi
source source params.conf
source $SCRIPTS_DIR/util_functions.sh

# check args
if [ "$#" -ne "2" ]; then usage; exit 1 ; fi
if [ ! -d "$1" ]; then echo "Dir does not exist : $1"; usage; exit 1 ; fi
if [  "$2" != "SERVER" ] && [ "$2" != "CLIENT" ]; then usage; exit 1 ; fi

TARGET="$2"
# global vars
BDIR=$PWD
FDIR=$1
LINUX="SLACKWARE"

echo "###############################################"
echo "# Configuring $TARGET ..."
if [ "$FORCE" -eq "1" ]; then 
    echo "# Forcing configuration ..."; 
fi
echo "###############################################"

# Configure root internet access
MSG="Configuring proxy for root"
start_msg "$MSG"
bname="/root/.bashrc"
if [ $(pattern_not_present "https_proxy" "${bname}") ]; then
    touch $bname
    backup_file $bname
    cat <<EOF > $bname
    # NOTE: This assumes cntlm is running and configured on server
    export PROXY="$PROXY"
    export http_proxy="http://\$PROXY"
    export https_proxy="http://\$PROXY" 
    export ftp_proxy="ftp://\$PROXY"
    export RSYNC_PROXY="\$PROXY" 
EOF
else
    echo "#    -> already configured."
fi
source /root/.bashrc
end_msg "$MSG"


MSG="Installing slpkg"
start_msg "$MSG"
if [ hash slpkg 2>/dev/null ] || [ $FORCE -ne 1 ]; then
    echo "#    -> already installed"
else
    cd ~/Downloads
    source /root/.bashrc
    wget -c https://gitlab.com/dslackw/slpkg/-/archive/3.4.3/slpkg-3.4.3.tar.gz
    tar xf slpkg-3.4.3.tar.gz
    cd slpkg-3.4.3
    ./install.sh
    backup_file /etc/slpkg/blacklist 
    cat <<EOF > /etc/slpkg/blacklist
 kernel-firmware
 kernel-generic
 kernel-generic-smp
 kernel-headers
 kernel-huge
 kernel-huge-smp
 kernel-modules
 kernel-modules-smp
 kernel-source

 mozilla-firefox
EOF
    slpkg upgrade
fi
end_msg "$MSG"

MSG="Configuring dhcpcd to send the mac to the dhcp server"
start_msg "$MSG"
if [ x"" != x"$(diff -q $FDIR/etc-dhcpcd.conf /etc/dhcpcd.conf)" ] || [ $FORCE -eq 1 ]; then 
    copy_config "$FDIR/etc-dhcpcd.conf" "/etc/dhcpcd.conf"
else 
   echo "#    -> already configured"
fi
end_msg "$MSG"

# network interfaces
MSG="Configuring network interfaces "
start_msg "$MSG"
if [ "$TARGET" == "SERVER" ]; then
    if [ $(pattern_not_present "127.0.0.1" "/etc/resolv.conf.head") ]; then
	echo "Setting up resolv.conf.head "
	TFILE="/etc/resolv.conf.head"
	copy_config "$FDIR/SERVER-etc-resolv.conf.head" "$TFILE"
    fi	
    if [ $(pattern_not_present "$SERVERIP" "/etc/rc.d/rc.inet1.conf") ]; then 
	bash /etc/rc.d/rc.networkmanager stop
	chmod -x /etc/rc.d/rc.networkmanager
	copy_config "$FDIR/SERVER-etc-rc.d-rc.inet1.conf" /etc/rc.d/rc.inet1.conf
    else
	echo "Already configured, just restarting services ..."
    fi
    /etc/rc.d/rc.inet1 restart
else
    echo "Creating Network Manager hook"
    if [ ! -f "/etc/NetworkManager/dispatcher.d/90networkmanagerhook.sh" ] || [ $FORCE -eq 1 ]; then
	cp $FDIR/CLIENT-90networkmanagerhook.sh /etc/NetworkManager/dispatcher.d/90networkmanagerhook.sh
	chmod +x /etc/rc.d/rc.networkmanager
	bash /etc/rc.d/rc.networkmanager restart
	/etc/rc.d/rc.inet2 restart
    else
	echo "#    -> already configured."
    fi
fi
end_msg "DONE: $MSG"

MSG="Fixing xinitrc on /etc/skel"
start_msg "$MSG"
if [ ! -f /etc/skel/.xinitrc ] || [ $FORCE -eq 1 ]; then 
    cp -f /etc/xdg/xfce4/xinitrc /etc/skel/.xinitrc
else
    echo "#    -> Already fixed"
fi
end_msg "$MSG"
MSG="Fixing xsession on /etc/skel"
start_msg "$MSG"
if [ ! -f /etc/skel/.xsession ] || [ $FORCE -eq 1 ]; then 
    cp -f /etc/xdg/xfce4/xinitrc /etc/skel/.xsession
else
    echo "#   -> Already fixed"
fi
end_msg "$MSG"


# latam keyboard
MSG="Configuring default X windows keyboard to be latam ..."
start_msg "$MSG"
bfile=/etc/X11/xorg.conf.d/90-keyboard-layout.conf
if [ $(pattern_not_present "la-latin1" "$bfile") ]; then 
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
    echo "#    -> already configured"
fi
end_msg "$MSG"


# ntp server
if [ "$TARGET" == "CLIENT" ]; then
    MSG="Configuring ntp "
    start_msg "$MSG"
    if [ $(pattern_not_present "$SERVERIP" "/etc/ntp.conf") ]; then
	bfile=/etc/ntp.conf
	backup_file $bfile
	cp -f $FDIR/CLIENT-ntp-client.conf $bfile
	chmod +x /etc/rc.d/rc.ntpd
	/etc/rc.d/rc.ntpd restart
    else
	    echo "#    -> already configured"
    fi
    end_msg "$MSG"
fi


# dnsmasq
MSG="Configuring dnsmasq "
if [ "$TARGET" == "SERVER" ]; then
    start_msg "$MGS"
    TFILE="/etc/dnsmasq.conf"
    if [ ! -f $TFILE ] || [ $FORCE -eq 1 ]; then  
	copy_config "$FDIR/SERVER-etc-dnsmasq.conf" "$TFILE"
	TFILE="/etc/dnsmasq-hosts.conf"
	copy_config "$FDIR/SERVER-etc-dnsmasq-hosts.conf" "$TFILE"
	chmod +x /etc/rc.d/rc.dnsmasq 
	TFILE="/etc/hosts"
	copy_config "$FDIR/SERVER-etc-hosts" "$TFILE"
    else
	echo "Already configured. Restarting services ..."
    fi
    /etc/rc.d/rc.dnsmasq restart
    end_msg "DONE: $MSG"
fi


# firewall : TODO get latest config
MSG="Configuring firewall "
if [ "$TARGET" == "SERVER" ]; then
    start_msg "$MSG"
    if [ hash arno-iptables-firewall 2>/dev/null ]  || [ $FORCE -ne 0 ]; then
	echo "    -> firewall already installed and configured."
    else
	#sbopkg -e stop -B -k -i arno-iptables-firewall
	source /root/.bashrc
	slpkg upgrade
	slpkg -s sbo arno-iptables-firewall-2.0.1e-noarch-3_SBo
	ln -svf /etc/rc.d/rc.arno-iptables-firewall /etc/rc.d/rc.firewall
	copy_config "$FDIR/SERVER-firewall.conf" "/etc/arno-iptables-firewall/firewall.conf"
	chmod o-rwx /etc/arno-iptables-firewall/firewall.conf
	chmod +x /etc/rc.d/rc.firewall
    fi
    /etc/rc.d/rc.firewall restart
    end_msg "$MSG"
fi
# read

# nfs
MSG="Configuring nfs "
start_msg "$MSG"
if [ "$TARGET" == "SERVER" ]; then
    if [ $(pattern_not_present "$BASE_SERVERIP" "/etc/hosts.allow") ]; then
	copy_config "$FDIR/SERVER-etc-hosts.allow" "/etc/hosts.allow"
    else
        echo "hosts allow already configured"
    fi
    if [ $(pattern_not_present "$SERVERIP" "/etc/exports") ]; then
	copy_config "$FDIR/SERVER-etc-exports" "/etc/exports"
    else
	echo "Exports already configured. Restarting services ..."
    fi
    chmod +x /etc/rc.d/rc.nfsd 
    /etc/rc.d/rc.nfsd restart
    /etc/rc.d/rc.inet2 restart
    echo "NOTE: If you have NFS problems, consider editing the /etc/hosts.allow and /etc/hosts.deny files"
else
    bfile="/etc/fstab"
    if [ $(pattern_not_present "${SERVERIP}" "$bfile") ]; then
	backup_file $bfile
	echo "# NEW NEW NEW NFS stuff " >> $bfile
	echo "${SERVERIP}:/home     /home   nfs     rw,hard,intr,usrquota  0   0" >> $bfile
    else
	echo "#    -> already configured"
    fi
    mount -a 
fi
end_msg "$MSG"




if [ "$TARGET" == "CLIENT" ]; then 
    MSG="Copying server public key  to configure passwordless access for root"
    start_msg "$MSG"
    mkdir -p /root/.ssh &>/dev/null
    if [ $(pattern_not_present "${SERVER_DOMAINNAME}" "/root/.ssh/authorized_keys") ]; then
	cat $FDIR/CLIENT-server_id_rsa.pub >> /root/.ssh/authorized_keys
	chmod 700 /root/.ssh
	chmod 640 /root/.ssh/authorized_keys
    else
	echo "#    -> already configured"
    fi
    end_msg "$MSG"
fi


MSG="Removing permissions to reboot/halt system"
start_msg "$MSG"
fname=disallow-power-options.rules
if [ ! -f /etc/polkit-1/rules.d/$fname ] || [ $FORCE -eq 1 ]; then
    chmod o-x /sbin/shutdown 
    chmod o-x /sbin/halt
    cp $FDIR/$fname /etc/polkit-1/rules.d/
else
    echo "#    -> polkit rules lready configured"
fi

tfname=/etc/acpi/acpi_handler.sh
if [ $(pattern_not_present "emoves" "$tfname") ]; then
    copy_config $FDIR/etc-acpi-acpi_handler.sh $tfname
else
    echo "#   -> Acpi handler already configured"
fi

end_msg "$MSG"


MSG="Configuring crontab "
start_msg "$MSG"
crontab -l > /tmp/crontab
if [ "$TARGET" == "SERVER" ]; then
    if [ $(pattern_not_present "network.sh" "/tmp/crontab") ] ; then 
	crontab $FDIR/SERVER-crontab -u root
    else
	echo "#    -> Already configured"
    fi
else
    if [ $(pattern_not_present "check_status.sh" "/tmp/crontab") ] ; then 
	crontab $FDIR/CLIENT-crontab -u root
    else
	echo "#    -> Already configured"
    fi
fi
echo "Adding install packages scripts to cron.hourly"
bname=install_upgrade_slackware_packages.sh
if [ ! -f /etc/cron.hourly/$bname ]; then
    cp $FDIR/etc-cron.hourly-$bname /etc/cron.hourly/$bname
fi

end_msg "$MSG"