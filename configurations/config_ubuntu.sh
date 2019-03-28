# global functions
function backup_file()
{
    if [ -e "$1" ]; then
        cp -v "$1" "$1".orig-$(date +%F--%H-%M-%S)
    fi
}

echo "Configuring network interface"
bfile=/etc/network/interfaces
backup_file $bfile
cat <<EOF > $bfile
auto eth0
iface eth0 inet dhcp
dns-nameservers ${SERVERIP}
EOF
/etc/init.d/networking restart
echo "DONE: Configuring network interface in UBUNTU"


# Mirror configuration : slackware mirror configured on config_slackware.sh
echo "Configuring packages mirrors"
bfile=/etc/apt/sources.list
backup_file $bfile
cat <<EOF > $bfile
deb mirror://mirrors.ubuntu.com/mirrors.txt precise main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-updates main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-backports main restricted universe multiverse
deb mirror://mirrors.ubuntu.com/mirrors.txt precise-security main restricted universe multiverse
#deb http://168.176.34.158/ubuntu/ precise main multiverse restricted universe
#deb http://168.176.34.158/ubuntu/ precise-updates main multiverse restricted universe
EOF
#apt-get update
#apt-get -y install emacs
echo "DONE: Configuring packages mirrors"


echo "Configuring ssh "
# apt-get install openssh-client openssh-server
mv /etc/ssh/ssh_host_* ./
dpkg-reconfigure openssh-server
service ssh restart
echo "DONE: Configuring ssh"


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
