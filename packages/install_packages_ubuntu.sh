PACKAGES=(emacs htop curl fortune git)

#sudo apt update
for pkg in ${PACKAGES[*]}; do 
	echo "Installing package : $pkg"
	sudo apt install -y $pkg 
	echo "Done"
done 

function check_package_installed {
    pkg_status=1
    if [ x"" != x"$(which $1)" ]; then
	echo "    Already installed : $1"
	pkg_status=0
    fi
}

echo "Configuring extra packages:"
echo " -> keepassxc ..."
check_package_installed keepassxc
if [ 1 == $pkg_status ] ; then  
    echo "HERE"
    read
    sudo add-apt-repository ppa:phoerious/keepassxc # do only once
    sudo apt install keepassxc
fi

# See: https://www.zerotier.com/download/
echo " -> zerotier-one ..."
check_package_installed zerotier-one
if [ 1 == $pkg_status ] ; then  
    curl -s https://install.zerotier.com | sudo bash
fi

# See: https://www.dropbox.com/install-linux
echo " -> Dropbox ..."
check_package_installed ~/.dropbox-dist/dropboxd
if [ 1 == $pkg_status ] ; then  
    cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
    ~/.dropbox-dist/dropboxd
fi

# Chrome:
check_package_installed google-chrome
if [ 1 == $pkg_status ] ; then  
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
echo " -> google-chrome ..."
    sudo dpkg -i google-chrome-stable_current_amd64.deb
fi

# syncthing
# See: https://apt.syncthing.net/
# Setup at https://docs.syncthing.net/users/autostart.html#linux
# To copy the systemd unit :
# sudo cp "/usr/lib/systemd/system/syncthing@.service" /etc/systemd/system/
echo " -> syncthing ..."
check_package_installed syncthing
if [ 1 == $pkg_status ] ; then  
    # Add the release PGP keys:
    curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
    # Add the "stable" channel to your APT sources:
    echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
    # Update and install syncthing:
    sudo apt update
    sudo apt install syncthing
fi

# xfce4 screensaver
# see:
echo " -> xfce4-screensaver ..."
check_package_installed xfce4-screensaver
if [ 1 == $pkg_status ]; then  
    sudo add-apt-repository ppa:xubuntu-dev/experimental
    sudo apt-get update
    sudo apt-get install xfce4-screensaver
fi 
