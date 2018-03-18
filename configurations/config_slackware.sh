########################################
# GENERAL SYSTEM SETTINGS
########################################

function backup_file()
{
    if [ -e "$1" ]; then
        cp -v "$1" "$1".orig-$(date +%F--%H-%M-%S)
    fi
}

echo
echo "##################################################"
echo "Starting configuration for slackware basebox. NOTE: This scripts tries to be idempotent."
echo "##################################################"
echo

echo "Changing default init to 4 ..."
if [ x"" == x"$(grep 'id?4?initdefault' /etc/inittab | grep -v grep)" ]; then
    sed -i.bck 's/id:3:initdefault:/id:4:initdefault:/' /etc/inittab
fi
echo "Done"

echo "Activating services for future starts: nfs ssh "
chmod +x /etc/rc.d/rc.nfsd && /etc/rc.d/rc.nfsd start
chmod +x /etc/rc.d/rc.sshd && /etc/rc.d/rc.sshd start
#chmod +x /etc/rc.d/rc.wireless
#chmod +x /etc/rc.d/rc.networkmanager
echo "Done"

echo "Configuring timezone to Bogota ..."
cp -f /usr/share/zoneinfo/America/Bogota /etc/localtime

echo "Configuring slim login manager"
if [ x"" == x"$(grep slim /etc/rc.d/rc.4 | grep -v grep)" ]; then
    sed -i.bck '/echo "Starting up X11 session manager..."/a \\n# start SLiM ...\nif [ -x /usr/bin/slim ]; then exec /usr/bin/slim; fi ' /etc/rc.d/rc.4
    ln -sf /etc/X11/xinit/xinitrc.xfce /etc/X11/xinitrc
fi

echo "Configuring slackpkg mirror"
bfile=/etc/slackpkg/mirrors
if [ x"1" != x"$(wc -l $bfile)" ]; then 
    cp /etc/slackpkg/mirrors{,bck}
    echo "http://slackware.mirrors.tds.net/pub/slackware/slackware-14.2/" > /etc/slackpkg/mirrors
else
    echo "    -> tds mirror already configured."
fi

echo "Adding dhcp for eth1"
sed -i.bck 's/USE_DHCP\[1\]=""/USE_DHCP\[1\]="yes"/' /etc/rc.d/rc.inet1.conf

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

echo "Configuring cronjob for updating slackware"
bname="update_slackware"
if [ ! -f /etc/cron.d/${bname}_cronjob ] || [ ! -f /root/scripts/${bname}.sh ]; then
    mkdir -p /root/scripts 2>/dev/null
    cp -f ${bname}.sh /root/scripts/
    cp -f ${bname}_cronjob /etc/cron.d/
else
    echo "    -> already configured ."
fi

echo "Done."
