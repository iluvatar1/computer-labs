#!/bin/bash

function usage() 
{
    echo "USAGE: "
    echo "config_server.sh DIR LINUX_FLAVOR"
    echo "DIR          : Where to find the model config files"
    echo "LINUX_FLAVOR : UBUNTU or SLACKWARE , in capital"
}

# check args
if [ "$#" -ne "2"]; then usage; exit 1 ; fi
if [ ! -d "$1" ]; then echo "Dir does not exist : $1"; usage; exit 1 ; fi
if [ "$2" -ne "UBUNTU" -o "$2" -ne "SLACKWARE"]; then usage; exit 1 ; fi

# global vars
BDIR=$PWD
FDIR=$1
LINUX=$2

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

# copy dot_bashrc
#cp $FDIR/dot_bashrc /root/.bashrc
#source /root/.bashrc

# network interfaces
echo "Configuring network interfaces for fixed ips "
if [ "$LINUX" == "SLACKWARE" ]; then
    bash /etc/rc.d/rc.networkmanager stop
    chmod -x /etc/rc.d/rc.networkmanager
    copy_config "$FDIR/SERVER-SLACKWARE-etc-rc.d-rc.inet1.conf" /etc/rc.d/rc.inet1.conf
    /etc/rc.d/rc.inet1 restart
elif [ "$LINUX" == "UBUNTU" ]; then
    copy_config "$FDIR/SERVER-UBUNTU-etc-network-interfaces" /etc/network/interfaces
    copy_config "$FDIR/SERVER-UBUNTU-etc-NetworkManager-NetworkManager.conf" /etc/NetworkManager/NetworkManager.conf
    /etc/init.d/networking restart
fi
echo "DONE: Configuring network interface"

# dnsmasq
echo "Configuring dnsmasq "
if [ "$LINUX" == "SLACKWARE" ]; then
    copy_config "$FDIR/SERVER-etc-dnsmasq.conf" "/etc/dnsmasq.conf"
    chmod +x /etc/rc.d/rc.dnsmasq 
    /etc/rc.d/rc.dnsmasq restart
elif [ "$LINUX" == "UBUNTU" ]; then
    apt-get -y install dnsmasq 
    copy_config "$FDIR/SERVER-etc-dnsmasq.conf" "/etc/dnsmasq.conf"
    #bfile="/etc/defaults/dnsmasq"
    #backup_file $bfile
    #echo "IGNORE_RESOLVCONF=yes" >> $bfile 
    /etc/init.d/networking stop
    service dnsmasq restart
    /etc/init.d/networking start
fi
echo "DONE: Configuring dnsmasq "
# read

# firewall
echo "Configuring firewall "
if [ "$LINUX" == "SLACKWARE" ]; then
    if [ ! hash arno-iptables-firewall 2>/dev/null ]; then
	sbopkg -e stop -B -k -i arno-iptables-firewall
	ln -sv /etc/rc.d/rc.arno-iptables-firewall /etc/rc.d/rc.firewall
	copy_config "$FDIR/SERVER-firewall.conf" "/etc/arno-iptables-firewall/firewall.conf"
	chmod +x /etc/rc.d/rc.firewall
    else
	echo "    -> firewall already installed and configured."
    fi
    /etc/rc.d/rc.firewall restart
elif [ "$LINUX" == "UBUNTU" ]; then
    apt-get -y install arno-iptables-firewall
    copy_config "$FDIR/SERVER-firewall.conf" "/etc/arno-iptables-firewall/firewall.conf"
    service arno-iptables-firewall restart
fi
echo "DONE: Configuring firewall "
# read


# kanif cluster tools
echo "Configuring kanif "
#ssh-keygen -t rsa
#for a in ssf6 ssf7 ssf8 ssf9; do
#    yes 'PASSWORD' | ssh-copy-id -i ~/.ssh/id_rsa.pub $q
#done
if [ "$LINUX" == "SLACKWARE" ]; then
    echo "Kanif assumed to be installed in slackware."
elif [ "$LINUX" == "UBUNTU" ]; then
    apt-get -y install kanif
fi
copy_config "$FDIR/SERVER-etc-c3.conf" "/etc/kanif.conf"
#kash ls
echo "DONE: Configuring kanif "
# read

# nfs
echo "Configuring nfs "
if [ "$LINUX" == "SLACKWARE" ]; then
    chmod +x /etc/rc.d/rc.nfsd 
    /etc/rc.d/rc.nfsd restart
    /etc/rc.d/rc.inet2 restart
elif [ "$LINUX" == "UBUNTU" ]; then
    apt-get -y install nfs-kernel-server
    service nfs-kernel-server restart
fi
copy_config "$FDIR/SERVER-etc-exports" "/etc/exports"
kash 'mount -a'
kash 'mount'
echo "DONE: Configuring nfs "
echo "NOTE: If you have problems, consider editing the /etc/hosts.allow and /etc/hosts.deny files"
# read

# nis
echo "Configuring nis "
copy_config "$FDIR/SERVER-etc-defaultdomain" "/etc/defaultdomain"
if [ "$LINUX" == "SLACKWARE" ]; then
elif [ "$LINUX" == "UBUNTU" ]; then
    #bfile="/etc/default/nis"
    #backup_file $bfile
    #sed -i.bck 's/NISSERVER=.*/NISSERVER=master/; s/NISCLIENT=.*/NISCLIENT=/' $bfile
    copy_config "$FDIR/SERVER-UBUNTU-etc-default-nis" "/etc/default/nis"
fi
#bfile="/etc/yp.conf"
#backup_file $bfile
#echo 'ypserver 192.168.123.1 ' > $bfile
copy_config "$FDIR/SERVER-etc-yp.conf" "/etc/yp.conf"
copy_config "$FDIR/SERVER-var-yp-Makefile" "/var/yp/Makefile"
make -C /var/yp
/usr/lib/yp/ypinit -m
if [ "$LINUX" == "SLACKWARE" ]; then
    chmod +x /etc/rc.d/rc.yp
    backup_file /etc/rc.d/rc.yp
    sed -i.bck 's/YP_CLIENT_ENABLE=.*/YP_CLIENT_ENABLE=0/ ; s/YP_SERVER_ENABLE=.*/YP_SERVER_ENABLE=1/ ;' /etc/rc.d/rc.yp
    /etc/rc.d/rc.yp restart
    /etc/rc.d/rc.inet2 restart
elif [ "$LINUX" == "UBUNTU" ]; then
    service portmap restart
    service ypserv restart
    service ypbind restart
    #kash service ypserv restart
fi
rpcinfo -p localhost # check
echo "DONE: Configuring nis "
# read

# Configure root internet access
echo "Configuring root proxy ..."
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
echo "Done."




