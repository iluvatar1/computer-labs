#!/bin/env bash

###############################################################################
# Config parameters
###############################################################################
SLPKG_PKGS=(valgrind valkyrie openmpi parallel modules cppcheck gperftools)
SPACK_PKGS=(gsl)

###############################################################################
# Functions definitions
###############################################################################
install_with_slpkg () {
    rm -f /var/log/slpkg.log
    slpkg update >> /var/log/slpkg.log
    for pkg in "${SLPKG_PKGS[@]}"; do
	# First check if package can be downloaded from droplet

	# Package must be compiled
	slpkg -s sbo "$pkg" >> /var/log/slpkg.log
    done
}

install_with_spack () {
    for pkg in "${SPACK_PKGS[@]}"; do
	spack install "$pkg"
    done
}

install_spack () {
    MSG="Installing Spack"
    echo "$MSG"
    sleep 2
    if [ ! -d /home/live/repos/spack ]; then
	mkdir -p /home/live/repos/ 
	cd /home/live/repos/ || exit 1
	git clone https://github.com/spack/spack 
	echo "source /home/live/repos/spack/share/spack/setup-env.sh" >> /home/live/.bashrc
	chown -R live /home/live/repos /home/live/.bashrc
	echo "Done"
    else
	echo "Already installed"
    fi
}

check_live_user () {
    MSG="Checking if live user exists, otherwise creating it ..."
    echo "$MSG"
    sleep 2
    if [ ! -d /home/live ]; then
	useradd -d /home/live -G audio,cdrom,floppy,plugdev,video -m -s /bin/bash live
	echo live:live | chpasswd
	echo "Done."
    else
	echo "Home dir already exists."
    fi
}

install_perf () {
    MSG="Installing perf ..."
    echo "$MSG"
    sleep 2

    if ! command perf 2>/dev/null; then
	cd /usr/src/linux/tools/perf || exit
	make -j 2 prefix=/usr/local install
	echo "Done"
    else
	echo "Already installed"
    fi
}

install_latest_firefox() {
    MSG="Installing latest firefox ..."
    echo "$MSG"
    sleep 2
    if [ x"" != x"$(firefox --version | grep esr)" ]; then
	cd
	if [ ! -d $HOME/repos/ ]; then
	    mkdir -p $HOME/repos
	fi 
	cd $HOME/repos || exit
	if [ ! -d computer-labs ]; then
	    git clone https://github.com/iluvatar1/computer-labs
	fi
	cd computer-labs || exit
	bash packages/latest-firefox.sh -i
	echo "Done"
    else
	echo "Already installed: $(firefox --version)"
    fi
}

###############################################################################
# Main 
###############################################################################
rm -f /var/log/log-install.txt 2>/dev/null
bash config_slackware.sh >> /var/log/log-install.txt
check_live_user >> /var/log/log-install.txt
install_with_slpkg >> /var/log/log-install.txt
install_spack >> /var/log/log-install.txt
install_with_spack >> /var/log/log-install.txt
install_perf >> /var/log/log-install.txt
install_latest_firefox >> /var/log/log-install.txt
