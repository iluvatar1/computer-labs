#!/bin/env bash

########################################
# GENERAL SYSTEM SETTINGS
########################################

pm () {
    echo "  -> $1"
}

backup_file()
{
    if [ -e "$1" ]; then
        cp -v "$1" "$1".orig-$(date +%F--%H-%M-%S)
    fi
}
configured()
{
    pm "Already configured $1"
}


inittab () {
    pm "Changing default init to 4 ..."
    if [ x"" = x"$(grep 'id:4:initdefault' /etc/inittab | grep -v grep)" ]; then
        sed -i.bck 's/id:3:initdefault:/id:4:initdefault:/' /etc/inittab
    else
	    configured 'inittab'
    fi
}

services_nfs_ssh () {
    pm "Activating services for future starts: nfs ssh "
    for fname in /etc/rc.d/rc.{nfsd,sshd}; do
	    if [ ! -x $fname ]; then
	        chmod +x $fname && $fname start
	    else
	        configured $fname
	    fi
    done
}

timezone () {
    pm "Configuring timezone to Bogota using script based on slackware timeconfig ..."
    #if [ x"" = x"$(grep timeconfig  /etc/rc.d/rc.local)" ]; then
    #    pm "Setting timezone and hardware clock in rc.local "
	#    TNAME="/etc/rc.d/rc.local"
	#    echo "# Setting up date and time " >> $TNAME
	#    echo "bash /root/repos/computer-labs/configurations/timeconfig" >> $TNAME
	#    echo "ntpdate 0.pool.ntp.org &> /dev/null" >> $TNAME
    #    bash /root/repos/computer-labs/configurations/timeconfig
    #fi
    ln -sf /usr/share/zoneinfo/America/Bogota /etc/localtime
    #sed -i.bck 's/localtime/UTC/' /etc/hardwareclock
    pm "Done"
}

ntp () {
    pm "Configuring more ntp servers ..."
    if [ x"" = x"$(grep co.pool /etc/ntp.conf | grep -v grep 2>/dev/null)" ]; then
        backup_file /etc/ntp.conf
	    echo "server   0.pool.ntp.org   iburst" >> /etc/ntp.conf
	    echo "server   0.co.pool.ntp.org   iburst" >> /etc/ntp.conf
    else
	    configured
    fi
    chmod +x /etc/rc.d/rc.ntpd
    /etc/rc.d/rc.ntpd restart
}

activate_wakeonlan () {
    # see: https://docs.slackware.com/howtos:network_services:wol
    pm "Activating wakeonlan on rc.local"
    if [ x"" = x"$(grep wol /etc/rc.d/rc.local | grep -v grep)" ]; then
        backup_file /etc/rc.d/rc.local
	    echo 'echo \"Setting Wake-on-LAN to Enabled\"' >> /etc/rc.d/rc.local
	    echo '/usr/sbin/ethtool -s eth0 wol g' >> /etc/rc.d/rc.local
    else
	    configured
    fi
    /usr/sbin/ethtool -s eth0 wol g
}

slackpkgmirror () {
    pm "Configuring slackpkg mirror"
    bfile=/etc/slackpkg/mirrors
    if [ x"1" != x"$(wc -l $bfile | awk '{print $1}')" ]; then 
        backup_file /etc/slackpkg/mirrors
	    echo "http://mirrors.slackware.com/slackware/slackware64-current/" > /etc/slackpkg/mirrors
    else
	    configured "mirror"
    fi
}

dhcp_eth1 () {
    pm "Adding dhcp for eth1"
    fname=/etc/rc.d/rc.inet1.conf
    if [ x"" = x"$(grep USE_DHCP\\[1\\]=\"yes\" $fname  | grep -v grep )" ]; then  
        sed -i.bck 's/USE_DHCP\[1\]=""/USE_DHCP\[1\]="yes"/' $fname
    else
	    configured
    fi
    chmod +x /etc/rc.d/rc.networkmanager
    /etc/rc.d/rc.networkmanager restart
    sleep 2
}

lilo_time () {
    # Configuring lilo
    pm "Configuring lilo delay time to 5 seconds ..."
    bname="/etc/lilo.conf"
    if [ x"" == x"$(grep -re 'timeout.*50' 2>/dev/null $bname)" ]; then
        backup_file $bname
	    sed -i.bck 's/timeout = 1200/timeout = 50/' $bname
    else
	    configured
    fi
    lilo
}


slpkg_aux () {
    pm "You might need to setup a proxy ..."
    sleep 5
    VERSION=$1
    mkdir ~/Downloads 2>/dev/null
    cd ~/Downloads || exit
    if [ -f /root/.bashrc ]; then 
        . /root/.bashrc
    fi
    wget -c -nc "https://gitlab.com/dslackw/slpkg/-/archive/$VERSION/slpkg-$VERSION.tar.gz"
    tar xf "slpkg-$VERSION.tar.gz"
    cd "slpkg-$VERSION" || exit
    ./install.sh
}

slpkg_install () {
    MSG="Installing slpkg"
    pm "$MSG"
    ##### installation #####
    if hash slpkg 2>/dev/null ; then
        pm "#    -> already installed"
    else
	    if hash python3 2>/dev/null && hash pip3 2>/dev/null; then
	        pip3 install urllib3
	        slpkg_aux 3.9.1
	    else # python 2
	        slpkg_aux 3.4.3
	    fi
    fi
    #### configuration ####
    fname=/etc/slpkg/slpkg.conf
    if [ x"" = x"$(grep 'DEFAULT_ANSWER=y' $fname | grep -v grep)" ]; then 
        backup_file /etc/slpkg/slpkg.conf
	    sed -i.bck 's/RELEASE=stable/RELEASE=current/' /etc/slpkg/slpkg.conf
	    sed -i.bck 's/DEFAULT_ANSWER=n/DEFAULT_ANSWER=y/' /etc/slpkg/slpkg.conf
	    sed -i.bck 's/DOWNDER_OPTIONS=.*/DOWNDER_OPTIONS=-c -N --no-check-certificate/' /etc/slpkg/slpkg.conf
        sed -i.bck 's/NOT_DOWNGRADE=off/NOT_DOWNGRADE=on/' /etc/slpkg/slpkg.conf
	    backup_file /etc/slpkg/repositories.conf
        for reponame in slack sbo alien; do
            sed -i.bck 's/^# '$reponame'$/'$reponame'/' /etc/slpkg/repositories.conf
        done
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
# mozilla-firefox
EOF
    else
	    configured
    fi
    #### PATCH to solve issues between proxy and urllib: use requests #####
    backup_file /usr/lib64/python3.9/site-packages/slpkg/file_size.py
    cp -f "$HOME/repos/computer-labs/packages/slpkg/file_size.py" /usr/lib64/python3.9/site-packages/slpkg/file_size.py
    # Update
    pm "Recommended to run : slpkg update"
    slpkg update
    pm "DONE: $MSG"
}

dhcpcd_clientid () {
    # This is useful for some dhpc servers that don understand the ipv6 stuff
    MSG="Configuring dhcpcd to send the mac to the dhcp server"
    pm "$MSG"
    fname=/etc/dhcpcd.conf
    if [ x"" = x"$(grep '^#duid' $fname | grep -v grep)" ] || [ x"" != x"$(grep '#clientid' $fname | grep -v grep)" ] ; then
        backup_file $fname
	    sed -i "s/^#clientid/clientid/" $fname
	    sed -i "s/^duid/#duid/" $fname
    else
	    configured
    fi
}

xorg_virtualmonitor () {
    pm "Configuring virtual monitor resolutions (virtualbox machine)"
    if [ ! -f /etc/X11/xorg.conf.d/11-monitor.conf ]; then
	cat << EOF > /etc/X11/xorg.conf.d/11-monitor.conf
	Section "Monitor"
     	Identifier "Virtual1"
    	Option "PreferredMode" "1680x1050"
	EndSection
EOF
    else
	    configured
    fi
}

start_msg () {
    pm "START: $1"
}

end_msg () {
    pm "END:   $1"
}

config_bashrc () {
    pm "Adding loading of /etc/profile to skeleton bashrc"
    if [ x"" = x"$(grep profile /etc/skel/.bashrc 2>/dev/null)" ]; then
        echo "source /etc/profile " >> /etc/skel/.bashrc
    else
	    configured
    fi
}

config_xinitrc () {
    MSG="Fixing xinitrc on /etc/skel"
    start_msg "$MSG"
    if [ ! -f /etc/skel/.xinitrc ]; then
        cp -f /etc/xdg/xfce4/xinitrc /etc/skel/.xinitrc
	    chmod +x /etc/skel/.xinitrc
    else
	    pm "#    -> Already fixed"
    fi
    end_msg "$MSG"
    MSG="Fixing xsession on /etc/skel"
    start_msg "$MSG"
    if [ ! -f /etc/skel/.xsession ]; then 
        cp -f /etc/xdg/xfce4/xinitrc /etc/skel/.xsession
    else
	    pm "#   -> Already fixed"
    fi
    end_msg "$MSG"
    MSG="Adding empty .Xauthority to /etc/skel"
    start_msg "$MSG"
    if [ ! -f /etc/skel/.Xauthority ]; then
        touch /etc/skel/.Xauthority
    else
	    pm "#    -> Already fixed"
    fi
    end_msg "$MSG"
}

# latam keyboard
config_latam_kbd () {
    MSG="Configuring default X windows keyboard to be latam ..."
    start_msg "$MSG"
    bfile=/etc/X11/xorg.conf.d/90-keyboard-layout.conf
    if [ x"" = x"$(grep latam ${bfile} 2>/dev/null)" ] ; then
        if [ -f $bfile ]; then
	        backup_file $bfile
	    fi
	cat<<EOF > $bfile
Section "InputClass"
        Identifier "keyboard defaults"
        MatchIsKeyboard "on"
        #MatchDevicePath "/dev/input/event*"
        #Driver "evdev"
        Option "XkbLayout" "latam,us"
        #Option "XkbVariant" ""
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF
        else
	    pm "#    -> already configured"
    fi
    end_msg "$MSG"
}

#####################################################
# MAIN
#####################################################
echo
echo "##################################################"
echo " -> Starting configuration for slackware basebox. NOTE: This scripts tries to be idempotent."
echo "##################################################"
echo

inittab
services_nfs_ssh
timezone
ntp
dhcp_eth1
lilo_time
dhcpcd_clientid
activate_wakeonlan
xorg_virtualmonitor
config_xinitrc
config_latam_kbd
config_bashrc
slpkg_install
slackpkgmirror

pm "Done."
