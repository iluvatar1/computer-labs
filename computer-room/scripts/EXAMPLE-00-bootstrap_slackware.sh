#!/bin/bash

# NOTE: The original base file is in the config_computer_room.org file

SCRIPTS_DIR=$HOME/repos/computer-labs/computer-room/scripts
CONFIG=${CONFIG:-params.conf}

if [ ! -f $CONFIG ]; then 
    echo "ERROR: Config file not found -> $CONFIG"
    exit 1
fi
source $CONFIG
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
if [[ $FORCE -eq 1 ]]; then 
    echo "# Forcing configuration ..."; 
fi
echo "###############################################"

# Configure root internet access
function config_proxy {
    MSG="Configuring proxy for root"
    start_msg "$MSG"
    bname="/root/.bashrc"
    if [ x"" == x"$(grep https_proxy ${bname})" ] || [ $FORCE -eq 1 ] ; then
	touch $bname
	backup_file $bname
	cat <<EOF > $bname
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
}

# network interfaces
function config_network {
    MSG="Configuring network interfaces "
    start_msg "$MSG"
    if [ "$TARGET" == "SERVER" ]; then
	#if [ $(pattern_not_present "127.0.0.1" "/etc/resolv.conf.head") ]; then
	if [ x"" == x"$(grep 127.0.0.1 /etc/resolv.conf.head)" ] || [ $FORCE -eq 1 ] ; then
	    echo "Setting up resolv.conf.head "
	    TFILE="/etc/resolv.conf.head"
	    copy_config "$FDIR/SERVER-etc-resolv.conf.head" "$TFILE"
	fi	
	#if [ $(pattern_not_present "$SERVERIP" "/etc/rc.d/rc.inet1.conf") ]; then 
	if [ x"" == x"$(grep $SERVERIP /etc/rc.d/rc/inet1.conf)" ] || [ $FORCE -eq 1 ] ; then
	    bash /etc/rc.d/rc.networkmanager stop
	    chmod -x /etc/rc.d/rc.networkmanager
	    copy_config "$FDIR/SERVER-etc-rc.d-rc.inet1.conf" /etc/rc.d/rc.inet1.conf
	else
	    echo "Already configured, just restarting services ..."
	fi
	/etc/rc.d/rc.inet1 restart
    else
	echo "# Creating Network Manager hook"
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
}

function config_xinitrc {
    MSG="Fixing xinitrc on /etc/skel"
    start_msg "$MSG"
    if [ ! -f /etc/skel/.xinitrc ] || [[ $FORCE -eq 1 ]]; then 
	cp -f /etc/xdg/xfce4/xinitrc /etc/skel/.xinitrc
	chmod +x /etc/skel/.xinitrc
    else
	echo "#    -> Already fixed"
    fi
    end_msg "$MSG"
    MSG="Fixing xsession on /etc/skel"
    start_msg "$MSG"
    if [ ! -f /etc/skel/.xsession ] || [[ $FORCE -eq 1 ]]; then 
	cp -f /etc/xdg/xfce4/xinitrc /etc/skel/.xsession
    else
	echo "#   -> Already fixed"
    fi
    end_msg "$MSG"
}

# latam keyboard
function config_latam_kbd {
    MSG="Configuring default X windows keyboard to be latam ..."
    start_msg "$MSG"
    bfile=/etc/X11/xorg.conf.d/90-keyboard-layout.conf
    #if [ $(pattern_not_present "latam" "$bfile") ]; then 
    if [ x"" == x"$(grep latam ${bfile} 2>/dev/null)" ] || [ $FORCE -eq 1 ] ; then
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
}

# ntp server
function config_ntp {
    MSG="Configuring ntp "
    if [ "$TARGET" == "CLIENT" ]; then
	start_msg "$MSG"
	#if [ $(pattern_not_present "$SERVERIP" "/etc/ntp.conf") ]; then
	if [ x"" == x"$(grep $SERVERIP /etc/ntp.conf)" ] || [ $FORCE -eq 1 ] ; then
            echo "STATUS -> $(pattern_not_present "$SERVERIP" "/etc/ntp.conf")"
	    bfile=/etc/ntp.conf
	    backup_file $bfile
	    cp -f $FDIR/CLIENT-ntp-client.conf $bfile
	    chmod +x /etc/rc.d/rc.ntpd
	    /etc/rc.d/rc.ntpd restart
	else
	    echo "#    -> already configured"
	fi
    else
	echo "# Not configuring ntp on server"
    fi
    end_msg "$MSG"
}

# dnsmasq
function config_dnsmasq {
    MSG="Configuring dnsmasq "
    start_msg "$MSG"
    if [ "$TARGET" == "SERVER" ]; then
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
	chmod +x /etc/rc.d/rc.dnsmasq 
	/etc/rc.d/rc.dnsmasq restart
    else
        echo "Not configuring on client" 
    fi
    end_msg "$MSG"
}

# firewall 
function config_firewall {
    MSG="Configuring firewall "
    if [ "$TARGET" == "SERVER" ]; then
	start_msg "$MSG"
	if $(command_exists arno-iptables-firewall) && [[ $FORCE -eq 0 ]]; then
	    echo "    -> firewall already installed and configured."
	else
	    #sbopkg -e stop -B -k -i arno-iptables-firewall
	    source /root/.bashrc
	    slpkg upgrade
	    #slpkg -s sbo arno-iptables-firewall-2.0.1e-noarch-3_SBo
	    slpkg -s sbo arno-iptables-firewall
	    ln -svf /etc/rc.d/rc.arno-iptables-firewall /etc/rc.d/rc.firewall
	    copy_config "$FDIR/SERVER-firewall.conf" "/etc/arno-iptables-firewall/firewall.conf"
	    chmod o-rwx /etc/arno-iptables-firewall/firewall.conf
	    chmod +x /etc/rc.d/rc.arno-iptables-firewall
	fi
	/etc/rc.d/rc.firewall restart
	end_msg "$MSG"
    fi
    # read
}

# nfs
function config_nfs {
    MSG="Configuring nfs "
    start_msg "$MSG"
    if [ "$TARGET" == "SERVER" ]; then
	#if [ $(pattern_not_present "$BASE_SERVERIP" "/etc/hosts.allow") ]; then
	if [ x"" == x"$(grep $BASE_SERVERIP /etc/hosts.allow)" ] || [ $FORCE -eq 1 ] ; then
	    copy_config "$FDIR/SERVER-etc-hosts.allow" "/etc/hosts.allow"
	else
            echo "hosts allow already configured"
	fi
	#if [ $(pattern_not_present "$SERVERIP" "/etc/exports") ]; then
	if [ x"" == x"$(grep $SERVERIP /etc/exports)" ] || [ $FORCE -eq 1 ] ; then
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
	#if [ $(pattern_not_present "${SERVERIP}" "$bfile") ]; then
	if [ x"" == x"$(grep ${SERVERIP} ${bfile})" ] || [ $FORCE -eq 1 ] ; then
	    backup_file $bfile
	    echo "# NEW NEW NEW NFS stuff " >> $bfile
	    echo "${SERVERIP}:/home     /home   nfs     rw,hard,intr,usrquota  0   0" >> $bfile
	else
	    echo "#    -> already configured"
	fi
    fi
    end_msg "$MSG"
}

# nis
function config_nis {
    MSG="Configuring nis "
    start_msg "$MSG"
    chmod +x /etc/rc.d/rc.yp
    if [ "$TARGET" == "SERVER" ]; then
        #if [ $(pattern_not_present "${NISDOMAIN}" "/etc/defaultdomain") ] ; then 
	if [ x"" == x"$(grep $NISDOMAIN /etc/defaultdomain)" ] || [ $FORCE -eq 1 ] ; then
            copy_config "$FDIR/SERVER-etc-defaultdomain" "/etc/defaultdomain"
        else
            echo "Already configured default nis domain"
        fi
        #if [ $(pattern_not_present "${NISDOMAIN}" "/etc/yp.conf") ] ; then 
	if [ x"" == x"$(grep $NISDOMAIN /etc/yp.conf)" ] || [ $FORCE -eq 1 ] ; then
            copy_config "$FDIR/SERVER-etc-yp.conf" "/etc/yp.conf"
            copy_config "$FDIR/SERVER-var-yp-Makefile" "/var/yp/Makefile"
        else
            echo "Already configured yp"
        fi

        backup_file /etc/rc.d/rc.yp
        if [ x"" == x"$(grep 'YP_SERVER_ENABLE=1' /etc/rc.d/rc.yp 2>/dev/null)"]; then 
            sed -i.bck 's/YP_CLIENT_ENABLE=.*/YP_CLIENT_ENABLE=0/ ; s/YP_SERVER_ENABLE=.*/YP_SERVER_ENABLE=1/ ;' /etc/rc.d/rc.yp
        else
            echo "Already configured as yp server"
        fi
	
        echo "Running nis services ..."
        ypserv
        make -BC /var/yp
        #/usr/lib64/yp/ypinit -m
    else
        chmod +x /etc/rc.d/rc.nfsd
        #if [ $(pattern_not_present "${NISDOMAIN}" "/etc/defaultdomain") ]; then
	if [ x"" == x"$(grep $NISDOMAIN /etc/defaultdomain)" ] || [ $FORCE -eq 1 ] ; then
            bfile="/etc/defaultdomain"
            backup_file $bfile
            echo ${NISDOMAIN} > $bfile  
	    bfile="/etc/rc.d/rc.local"
	    backup_file $bfile
	    echo 'nisdomainname -F /etc/defaultdomain' > $bfile
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
            if [ x"" == x"$(grep 'YP_CLIENT_ENABLE=1' /etc/rc.d/rc.yp) 2>/dev/null" ]; then 
                backup_file /etc/rc.d/rc.yp
                sed -i.bck 's/YP_CLIENT_ENABLE=.*/YP_CLIENT_ENABLE=1/ ; s/YP_SERVER_ENABLE=.*/YP_SERVER_ENABLE=0/ ;' /etc/rc.d/rc.yp
            fi
        else
            echo "#    -> already configured."
        fi
    fi
    nisdomainname -F /etc/defaultdomain
    end_msg "$MSG"
}

function config_monit {
    MSG="Configuring monit on server "
    start_msg "$MSG"
    if [ "$TARGET" == "SERVER" ]; then 
	if $(command_exists monit) && [[ $FORCE -eq 0 ]]; then
	    echo "#    -> already installed"
	else
	    source /root/.bashrc
	    slpkg -s sbo monit
	    chmod +x /etc/rc.d/rc.monit 
	    backup_file /root/.monitrc
	    copy_config "$FDIR/SERVER-root-dotmonitrc" "/root/.monitrc"
	    backup_file /etc/rc.d/rc.local
	    echo "/usr/bin/monit -c /root/.monitrc &> /var/log/log-monit-root&" >> /etc/rc.d/rc.local
	    /etc/rc.d/rc.monit restart
	fi
    else
	echo "Not configuring on client (for now)."
    fi
    end_msg "$MSG"
}

function config_publicid_sshpassword {
    if [ "$TARGET" == "CLIENT" ]; then 
	MSG="Copying server public key  to configure passwordless access for root"
	start_msg "$MSG"
	mkdir -p /root/.ssh &>/dev/null
	#if [ $(pattern_not_present "${SERVER_DOMAINNAME}" "/root/.ssh/authorized_keys") ]; then
	if [ x"" == x"$(grep $SERVER_DOMAINNAME /root/.ssh/authorized_keys)" ] || [ $FORCE -eq 1 ] ; then
	    cat $FDIR/CLIENT-server_id_rsa.pub >> /root/.ssh/authorized_keys
	    chmod 700 /root/.ssh
	    chmod 640 /root/.ssh/authorized_keys
	else
	    echo "#    -> already configured"
	fi
	end_msg "$MSG"
	
	MSG="Allowing root login for client"
	start_msg "$MSG"
	bfile="/etc/ssh/sshd_config"
	if [ x"" == x"$(grep '^PermitRootLogin.*yes' $bfile)" ] || [ $FORCE -eq 1 ] ; then
	    backup_file $bfile
	    echo "PermitRootLogin yes" >> $bfile
	    /etc/rc.d/rc.sshd restart
	else
	    echo "#    -> already_configured"
	fi
	end_msg "$MSG"
    fi

}

function config_shutdown_perms {
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
    #if [ $(pattern_not_present "emoves" "$tfname") ]; then
    if [ x"" == x"$(grep emoves ${tfname})" ] || [ $FORCE -eq 1 ] ; then
	copy_config $FDIR/etc-acpi-acpi_handler.sh $tfname
    else
	echo "#   -> Acpi handler already configured"
    fi

    end_msg "$MSG"
}

function config_crontab {
    MSG="Configuring crontab per minute, hour, daily, etc"
    start_msg "$MSG"
    crontab -l > /tmp/crontab
    if [ "$TARGET" == "SERVER" ]; then
	if [ x"" == x"$(grep minute_maintenance.sh /tmp/crontab)" ] || [ $FORCE -eq 1 ] ; then
	    crontab $FDIR/SERVER-crontab -u root
	else
	    echo "#    -> Already configured (per minute)"
	fi
	TNAME="/etc/cron.daily/daily_maintenance.sh"
	if [ ! -f $TNAME ] || [ $FORCE -eq 1 ]; then
            copy_config $FDIR/SERVER-cron/daily_maintenance.sh "$TNAME"
	else
            echo "#    -> Already configured (daily)"
	fi
    else # CLIENT
	if [ x"" == x"$(grep check_status.sh /tmp/crontab)" ] || [ $FORCE -eq 1 ] ; then
	    crontab $FDIR/CLIENT-crontab -u root
	else
	    echo "#    -> Already configured"
	fi
    fi
    end_msg "$MSG"
}

function config_cntlm {
    MSG="Configuring cntlm on server "
    start_msg "$MSG"
    if [ "$TARGET" == "SERVER" ]; then 
	if $(command_exists cntlm) && [ $FORCE -eq 0 ]; then
	    echo "#    -> already installed"
	else
	    source /root/.bashrc
	    slpkg -s sbo cntlm
	    chmod +x /etc/rc.d/rc.cntlm 
	    backup_file /etc/cntlm.conf
	    copy_config "$FDIR/SERVER-etc-cntlm.conf" "/etc/cntlm.conf"
	    echo "Please write the password for the account to be used with cntlm"
	    cntlm -H > /tmp/cntlm-hashed
	    cat /tmp/cntlm-hashed >> /etc/cntlm.conf
	    rm -f /tmp/cntlm-hashed
	    /etc/rc.d/rc.cntlm restart
	fi
    else
	echo "Not configuring on client."
    fi
    end_msg "$MSG"
}

function config_slim {
    MSG="Installing and configuring slim "
    start_msg "$MSG"
    if $(command_exists slim) && [[ $FORCE -eq 0 ]]; then
	echo "#    -> already installed"
    else
	source /root/.bashrc
	slpkg -s sbo slim
	# The script config_slackware already added slim as an alternative 
	# TODO Setup a nicer theme
    fi
    end_msg "$MSG"
}

# Call all functions
config_proxy
config_network
config_xinitrc
config_latam_kbd
config_ntp
config_dnsmasq
config_firewall
config_nfs
config_nis
config_monit
config_publicid_sshpassword
config_shutdown_perms
config_crontab
config_packages
config_cntlm
config_slim

# run services (better done on script that keeps the system up, when the client is on the network)
#/etc/rc.d/rc.nfsd restart
#mount -a 
#/etc/rc.d/rc.yp restart    
#/etc/rc.d/rc.inet2 restart
#rpcinfo -p localhost
