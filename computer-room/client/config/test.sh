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


echo "Adding dhcp for eth1"
sed -i.bck 's/USE_DHCP\[1\]=""/USE_DHCP\[1\]="yes"/' /etc/rc.d/rc.inet1.conf

# Mirror configuration
echo "Configuring packages mirrors"
if [ "$LINUX" == "SLACKWARE" ]; then
    bfile=/etc/slackpkg/mirrors
    if [ x"" == x"$(grep tds $bfile)" ]; then 
	backup_file $bfile
	cat <<EOF > $bfile
http://s    lackware.mirrors.tds.net/pub/slackware/slackware-14.2/
EOF
	slackpkg update
    fi
fi

# la latin keyboard
echo "Configuring default X windows keyboard to be la-latin1 ..."
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
        Option "XkbLayout" "la-latin1"
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
    cp -f $FDIR/cron/check_status.sh /root/scripts/
    cp -f $FDIR/cron/check_status_cronjob /etc/cron.d/
else
    echo "    -> already configured ."
fi

echo "Removing other people permissions from /sbin/shutdown and /sbin/halt"
chmod o-x /sbin/shutdown 
chmod o-x /sbin/halt 

