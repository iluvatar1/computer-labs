# fix apt slow mirrors
echo "Updating mirrors ..."
if [ "" == "$(grep edatel /etc/apt/sources.list | grep -v grep)" ]; then
    mv /etc/apt/sources.list /etc/apt/sources.list.old               
    cat <<EOF >> /etc/apt/sources.list
deb http://mirrors.advancedhosters.com/linuxmint/packages rosa main upstream import
#deb http://extra.linuxmint.com rosa main                         
deb http://mirror.edatel.net.co/ubuntu trusty main restricted universe multiverse
deb http://mirror.edatel.net.co/ubuntu trusty-updates main restricted universe multiverse
#deb http://security.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse
#deb http://archive.canonical.com/ubuntu/ trusty partner          
EOF
fi                                                                   

echo "Updating apt-get"
apt-get update --fix-missing -y &> /dev/null

echo "Installing kernel headers, build, and virtualbox guest additions"
apt-get install -y linux-headers-$(uname -r) build-essential dkms
apt-get install -y wget
VBOX_ADD=VBoxGuestAdditions_5.0.14.iso
if [ ! -f ${VBOX_ADD} ]; then 
    wget -c http://download.virtualbox.org/virtualbox/5.0.14/${VBOX_ADD}
fi
mkdir /media/VBoxGuestAdditions 2>/dev/null
mount -o loop,ro ${VBOX_ADD} /media/VBoxGuestAdditions
sh /media/VBoxGuestAdditions/VBoxLinuxAdditions.run
rm ${VBOX_ADD}
umount /media/VBoxGuestAdditions
rmdir /media/VBoxGuestAdditions

echo "Installing openssh-server"
apt-get install -y openssh-server

echo "Copying vagrant ssh keys"
mkdir /home/vagrant/.ssh
cd /home/vagrant/.ssh
mv vagrant vagrant.old
mv vagrant.pub vagrant.pub.old
wget https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant 
wget https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
cat vagrant.pub > authorized_keys
chown -R vagrant.vagrant /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
chmod 644 /home/vagrant/.ssh/vagrant.pub
chmod 600 /home/vagrant/.ssh/vagrant
cd 

echo "Changing root password to vagrant"
echo "root:vagrant" | chpasswd

echo "Configuring passwordless sudo"
if [ "" == "$(grep vagrant /etc/sudoers)" ]; then
    echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
fi
echo "Done."
