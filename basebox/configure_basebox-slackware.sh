echo "Configuring slackpkg mirror"
if [ x"1" != x"$(wc -l /etc/slackpkg/mirrors | awk '{print $1}')" ]; then
    cp /etc/slackpkg/mirrors{,bck}
    echo "http://mirrors.slackware.com/slackware/slackware64-14.2/" > /etc/slackpkg/mirrors
else
    echo "    -> already configured."
fi

#echo "Update slackpkg and install security patches ..."
#slackpkg update gpg # only the first time
#slackpkg update
#slackpkg upgrade patches
#slackpkg upgrade-all
#slackpkg install-new

echo "Installing virtualbox guest additions"
if ! hash vboxmanage &> /dev/null; then 
    VBOX_ADD=VirtualBox-5.1.8-111374-Linux_x86.run
    if [ ! -f ${VBOX_ADD} ]; then 
	wget -c http://download.virtualbox.org/virtualbox/5.1.8/${VBOX_ADD}
    fi
    bash ${VBOX_ADD} 
    #rm ${VBOX_ADD}
else
    echo "    -> already installed"
fi

echo "Adduser vagrant with password vagrant ... "
if [ x"" == x"$(grep vagrant /etc/passwd)" ]; then
    useradd -m -p vagrant vagrant
    echo "vagrant:vagrant" | chpasswd
else
    echo "    -> already added."
fi

echo "Copying vagrant ssh keys ..."
if [ x"" == x"$(grep vagrant /home/vagrant/.ssh/authorized_keys 2> /dev/null)" ]; then
    mkdir /home/vagrant/.ssh
    cd /home/vagrant/.ssh
    mv vagrant{,.old} &> /dev/null
    mv vagrant.pub{,.old} &> /dev/null
    wget https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant 
    wget https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
    cat vagrant.pub > authorized_keys
    chown -R vagrant /home/vagrant/.ssh
    chmod 700 /home/vagrant/.ssh
    chmod 600 /home/vagrant/.ssh/{authorized_keys,vagrant,vagrant.pub}
    cd
else
    echo "    -> already configured."
fi

echo "Changing root password to vagrant"
echo "root:vagrant" | chpasswd

echo "Configuring passwordless sudo ..."
if [ x"" == x"$(grep vagrant /etc/sudoers)" ]; then
    echo "vagrant ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
else
    echo "    -> already configured."
fi

echo "##################################################"
echo "Done."
echo "##################################################"
