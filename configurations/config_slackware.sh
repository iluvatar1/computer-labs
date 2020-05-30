########################################
# GENERAL SYSTEM SETTINGS
########################################

function backup_file()
{
    if [ -e "$1" ]; then
        cp -v "$1" "$1".orig-$(date +%F--%H-%M-%S)
    fi
}
function configured()
{
    echo "    -> Already configured $1"
}

echo
echo "##################################################"
echo "Starting configuration for slackware basebox. NOTE: This scripts tries to be idempotent."
echo "##################################################"
echo

function inittab {
    echo "Changing default init to 4 ..."
    if [ x"" = x"$(grep 'id:4:initdefault' /etc/inittab | grep -v grep)" ]; then
	sed -i.bck 's/id:3:initdefault:/id:4:initdefault:/' /etc/inittab
    else
	configured
    fi
}

function services_nfs_ssh {
    echo "Activating services for future starts: nfs ssh "
    for fname in /etc/rc.d/rc.{nfsd,sshd}; do
	if [ ! -x $fname ]; then
	    chmod +x $fname && $fname start
	else
	    configured $fname
	fi
    done
}

function timezone {
    echo "Configuring timezone to Bogota ..."
    if [ x"" != x"$(diff /usr/share/zoneinfo/America/Bogota /etc/localtime)" ]; then 
	#cp -f /usr/share/zoneinfo/America/Bogota /etc/localtime
	expect set_bogota_tz.exp 
    else
	configured
    fi
}

ntp () {
    echo "Configuring ntp server ..."
    if [ x"" = x"$(grep co.pool /etc/ntp.conf | grep -v grep 2>/dev/null)" ]; then
	backup_file /etc/ntp.conf
	echo "server   0.pool.ntp.org   iburst" >> /etc/ntp.conf
	echo "server   0.co.pool.ntp.org   iburst" >> /etc/ntp.conf
    else
	configured
    fi
    /etc/rc.d/rc.ntpd restart
}

function activate_wakeonlan {
    # see: https://docs.slackware.com/howtos:network_services:wol
    echo "Activating wakeonlan on rc.local"
    if [ x"" = x"$(grep wol /etc/rc.d/rc.local | grep -v grep)" ]; then
	backup_file /etc/rc.d/rc.local
	echo 'echo \"Setting Wake-on-LAN to Enabled\"' >> /etc/rc.d/rc.local
	echo '/usr/sbin/ethtool -s eth0 wol g' >> /etc/rc.d/rc.local
    else
	configured
    fi
    /usr/sbin/ethtool -s eth0 wol g
}

xdm_theme_install () {
    echo "Installing xdm theme"
    slpkg -s sbo xdm-slackware-theme
}

xfce4_plugins_install () {
    echo "Installing xfce4 plugins ..."
    slpkg -s sbo xfce4-xkb-plugin
}

function slim_install_config {
    echo "Installing/Configuring slim login manager"
    if [ x"" = x"$(grep slim /etc/rc.d/rc.4 | grep -v grep)" ]; then
	backup_file /etc/rc.d/rc.4
	sed -i.bck '/echo "Starting up X11 session manager..."/a \\n# start SLiM ...\nif [ -x /usr/bin/slim ]; then exec /usr/bin/slim; fi ' /etc/rc.d/rc.4
	ln -sf /etc/X11/xinit/xinitrc.xfce /etc/X11/xinitrc
    else
	configured
    fi
    if hash slim 2>/dev/null; then
	echo "Slim already installed"
    else
	slpkg -s sbo slim
    fi
    # change theme to slackware black
    if [ x"" = x"$(grep slackware-black /etc/slim.conf | grep -v grep)" ]; then
	backup_file /etc/slim.conf
	sed -i 's/current_them.*default/current_theme     slackware-black/' /etc/slim.conf
    else
	echo "Slim: slackware-black theme already configured"
    fi
}

function slackpkgmirror {
    echo "Configuring slackpkg mirror"
    bfile=/etc/slackpkg/mirrors
    if [ x"1" != x"$(wc -l $bfile | awk '{print $1}')" ]; then 
	backup_file /etc/slackpkg/mirrors
	echo "http://mirrors.slackware.com/slackware/slackware64-14.2/" > /etc/slackpkg/mirrors
    else
	configured "mirror"
    fi
}

function dhcp_eth1 {
    echo "Adding dhcp for eth1"
    fname=/etc/rc.d/rc.inet1.conf
    if [ x"" = x"$(grep USE_DHCP\\[1\\]=\"yes\" $fname  | grep -v grep )" ]; then  
	sed -i.bck 's/USE_DHCP\[1\]=""/USE_DHCP\[1\]="yes"/' $fname
    else
	configured
    fi
    chmod +x /etc/rc.d/rc.networkmanager
    /etc/rc.d/rc.networkmanager restart
    /etc/rc.d/rc.networkmanager restart
    sleep 2
}

function lilo_time {
    # Configuring lilo
    echo "Configuring lilo delay time to 5 seconds ..."
    bname="/etc/lilo.conf"
    if [ x"" == x"$(grep -re 'timeout.*50' 2>/dev/null $bname)" ]; then
	backup_file $bname
	sed -i.bck 's/timeout = 1200/timeout = 50/' $bname
    else
	configured
    fi
    lilo
}

function cron_update_slackware {
    echo "Configuring cronjob for updating slackware patches and firefox"
    bname="$HOME/repos/computer-labs/configurations/install_upgrade_slackware_packages.sh"
    if [ ! -f "/etc/cron.weekly/${bname}" ]; then
	mkdir -p /root/scripts 2>/dev/null
	cp -f ${bname} /etc/cron.weekly/
    else
	configured
    fi
}

function slpkg_aux {
    echo "You might need to setup a proxy ..."
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
function slpkg_install {
    MSG="Installing slpkg"
    echo "$MSG"
    ##### installation #####
    if hash slpkg 2>/dev/null ; then
	echo "#    -> already installed"
    else
	if hash python3 2>/dev/null && hash pip3 2>/dev/null; then
	    pip3 install urllib3
	    slpkg_aux 3.8.8
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
    echo "Recommended to run : slpkg update"
    slpkg update
    echo "DONE: $MSG"
}

function dhcpcd_clientid {
    # This is useful for some dhpc servers that don understand the ipv6 stuff
    MSG="Configuring dhcpcd to send the mac to the dhcp server"
    echo "$MSG"
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
    echo "Configuring virtual monitor resolutions (virtualbox machine)"
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
    echo "$1"
}

end_msg () {
    echo "$1"
}

config_bashrc () {
    echo "Adding loading of /etc/profile to skeleton bashrc"
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
	echo "#    -> Already fixed"
    fi
    end_msg "$MSG"
    MSG="Fixing xsession on /etc/skel"
    start_msg "$MSG"
    if [ ! -f /etc/skel/.xsession ]; then 
	cp -f /etc/xdg/xfce4/xinitrc /etc/skel/.xsession
    else
	echo "#   -> Already fixed"
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
	echo "#    -> already configured"
    fi
    end_msg "$MSG"
}

#####################################################
# MAIN
#####################################################

inittab
services_nfs_ssh
timezone
slpkg_install
ntp
#slim_install_config
xdm_theme_install
xfce4_plugins_install
slackpkgmirror
dhcp_eth1
lilo_time
# cron_update_slackware # This is better to be run after testing on one machine
dhcpcd_clientid
activate_wakeonlan
xorg_virtualmonitor
config_xinitrc
config_latam_kbd
config_bashrc

echo "Done."
