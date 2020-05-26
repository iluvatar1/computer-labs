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
    slpkg update
    for pkg in "${SPACK_PKGS[@]}"; do
	slpkg -s sbo "$pkg"
    done
}

install_with_spack () {
    for pkg in "${SLPKG_PKGS[@]}"; do
	spack install "$pkg"
    done
}

install_spack () {
    MSG="Installing Spack"
    echo "$MSG"
    sleep 2
    if [ ! -d /home/live/repos/spack ]; then
	su - live
	mkdir -p /home/live/repos/ 
	cd /home/live/repos/ || exit 1
	git clone https://github.com/spack/spack 
	echo "source /home/live/repos/spack/share/spack/setup-env.sh" >> ~/.bashrc
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


###############################################################################
# Main 
###############################################################################
bash config_slackware.sh 
check_live_user
install_with_slpkg
install_spack
install_with_spack
install_perf
bash /root/repos/computer-labs/packages/latest-firefox.sh -i
