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
	cp -f /usr/share/zoneinfo/America/Bogota /etc/localtime
    else
	configured
    fi
}

function slim {
    echo "Configuring slim login manager"
    if [ x"" == x"$(grep slim /etc/rc.d/rc.4 | grep -v grep)" ]; then
	backup_file /etc/rc.d/rc.4
	sed -i.bck '/echo "Starting up X11 session manager..."/a \\n# start SLiM ...\nif [ -x /usr/bin/slim ]; then exec /usr/bin/slim; fi ' /etc/rc.d/rc.4
	ln -sf /etc/X11/xinit/xinitrc.xfce /etc/X11/xinitrc
    else
	configured
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
}

function lilo {
    # Configuring lilo
    echo "Configuring lilo delay time to 5 seconds ..."
    bname="/etc/lilo.conf"
    if [ x"" == x"$(grep -re 'timeout.*50' 2>/dev/null $bname)" ]; then
	backup_file $bname
	sed -i.bck 's/timeout = 1200/timeout = 50/' $bname
	lilo
    else
	configured
    fi
}

function cron_update_slackware {
    echo "Configuring cronjob for updating slackware"
    bname="update_slackware"
    if [ ! -f /etc/cron.d/${bname}_cronjob ] || [ ! -f /root/scripts/${bname}.sh ]; then
	mkdir -p /root/scripts 2>/dev/null
	cp -f ${bname}.sh /root/scripts/
	cp -f ${bname}_cronjob /etc/cron.d/
    else
	configured
    fi
}

function slpkg_aux {
    echo "You might need to setup a proxy ..."
    sleep 5
    VERSION=$1
    cd ~/Downloads
    source /root/.bashrc
    wget -c https://gitlab.com/dslackw/slpkg/-/archive/$VERSION/slpkg-$VERSION.tar.gz
    tar xf slpkg-$VERSION.tar.gz
    cd slpkg-$VERSION
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
	    slpkg_aux 3.8.2
	else # python 2
	    slpkg_aux 3.4.3
	fi
    fi
    #### configuration ####
    fname=/etc/slpkg/slpkg.conf
    if [ x"" = x"$(grep 'DEFAULT_ANSWER=y' $fname | grep -v grep)" ]; then 
	backup_file /etc/slpkg/slpkg.conf
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
      
      mozilla-firefox
EOF
    else
	configured
    fi
    echo "Recommended to run : slpkg upgrade"
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

inittab
services_nfs_ssh
timezone
slim
slackpkgmirror
dhcp_eth1
lilo
cron_update_slackware
slpkg_install
dhcpcd_clientid

echo "Done."
