function usage() 
{
    echo "USAGE: "
    echo "config_server.sh DIR LINUX_FLAVOR"
    echo "DIR          : Where to find the model config files"
    echo "LINUX_FLAVOR : UBUNTU or SLACKWARE , in capital"
}

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


# check args
if [ "$#" -ne "2" ]; then usage; exit 1 ; fi
if [ ! -d "$1" ]; then echo "Dir does not exist : $1"; usage; exit 1 ; fi
if [ "$2" -ne "UBUNTU" -o "$2" -ne "SLACKWARE" ]; then usage; exit 1 ; fi

# global vars
BDIR=$PWD
FDIR=$1
LINUX=$2


# Configure root internet access
echo "Configuring root proxy ..."
bname="/root/.bashrc"
if [ x"" == "$(grep https_proxy ${bname} 2>/dev/null)" ]; then
    echo 'export PROXY="fisicasop_fcbog:s4l4fis219@proxyapp.unal.edu.co:8080/" ' >> $bname
    echo 'export http_proxy="http://$PROXY" ' >> $bname
    echo 'export https_proxy="https://$PROXY" ' >> $bname
    echo 'export ftp_proxy="ftp://$PROXY" ' >> $bname
    echo 'export RSYNC_PROXY="$PROXY" ' >> $bname
else
    echo "Root proxy already configured."
fi
source /root/.bashrc
echo "Done."

MSG="Installing sbopkg"
if [ "$LINUX" == "SLACKWARE" ]; then
    echo $MSG
    installpkg "$FDIR/sbopkg-0.38.1-noarch-1_wsr.tgz"
    echo "DONE: $MSG"
fi
MSG="Configuring dhcpcd to send the mac to the dhcp server"
echo $MSG
copy_config "$FDIR/SERVER-SLACKWARE-etc-dhcpcd.conf" "/etc/dhcpcd.conf"
echo "DONE: $MSG"
# network interfaces
MSG="Configuring network interfaces with fixed ip"
echo $MSG
if [ "$LINUX" == "SLACKWARE" ]; then
    bash /etc/rc.d/rc.networkmanager stop
    chmod -x /etc/rc.d/rc.networkmanager
    copy_config "$FDIR/SERVER-SLACKWARE-etc-rc.d-rc.inet1.conf" /etc/rc.d/rc.inet1.conf
    /etc/rc.d/rc.inet1 restart
    echo "Setting up resolv.conf.head "
    TFILE="/etc/resolv.conf.head"
    copy_config "$FDIR/SERVER-etc-resolv.conf.head" "$TFILE"
elif [ "$LINUX" == "UBUNTU" ]; then
    copy_config "$FDIR/SERVER-UBUNTU-etc-network-interfaces" /etc/network/interfaces
    copy_config "$FDIR/SERVER-UBUNTU-etc-NetworkManager-NetworkManager.conf" /etc/NetworkManager/NetworkManager.conf
    /etc/init.d/networking restart
fi
echo "DONE: $MSG"
# dnsmasq
MSG="Configuring dnsmasq "
echo $MGS
if [ "$LINUX" == "SLACKWARE" ]; then
    TFILE="/etc/dnsmasq.conf"
    copy_config "$FDIR/SERVER-etc-dnsmasq.conf" "$TFILE"
    TFILE="/etc/dnsmasq-hosts.conf"
    copy_config "$FDIR/SERVER-etc-dnsmasq-hosts.conf" "$TFILE"
    chmod +x /etc/rc.d/rc.dnsmasq 
    TFILE="/etc/hosts"
    copy_config "$FDIR/SERVER-etc-hosts" "$TFILE"
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
echo "DONE: $MSG"

# firewall
MSG="Configuring firewall "
echo $MSG
if [ "$LINUX" == "SLACKWARE" ]; then
    if [ ! hash arno-iptables-firewall 2>/dev/null ]; then
	sbopkg -e stop -B -k -i arno-iptables-firewall
	ln -svf /etc/rc.d/rc.arno-iptables-firewall /etc/rc.d/rc.firewall
	copy_config "$FDIR/SERVER-firewall.conf" "/etc/arno-iptables-firewall/firewall.conf"
	chmod o-rwx /etc/arno-iptables-firewall/firewall.conf
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
    echo "$LINUX : Nothing to be done. "
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
ypserv
make -BC /var/yp
#/usr/lib64/yp/ypinit -m
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
