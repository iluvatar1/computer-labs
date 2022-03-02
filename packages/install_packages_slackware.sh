#!/bin/env bash

# fix PATH to remove anaconda stuff
export PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/games:/usr/lib64/kde4/libexec:/usr/lib64/qt/bin:/usr/share/texmf/bin
\
################################################################################
COMPILE=${COMPILE:-NO}
MIRROR_ONLY=${MIRROR_ONLY:-NO}
PKGSERVER=${PKGSERVER:-192.168.10.1}
BASEURL="$PKGSERVER/PACKAGES/slackware64-current/"
LOG_FILE=${LOG_FILE:-/tmp/log-packages.txt}

PKG="keepassx sshfs-fuse autossh xfce4-xkb-plugin flashplayer-plugin slim monit \
    fail2ban corkscrew pip parallel wol valgrind openmpi modules cppcheck iotop gperftools \
    xdm-slackware-theme"

pm () {
    echo "  -> $1"
}

setup () {
    echo "Setting up slpkg"
    if hash slpkg &> /dev/null; then
        pm "Updating slpkg ..."
        source /root/.bashrc
        slpkg upgrade
    else
        pm "ERROR: slpkg not installed. Exiting"
        exit 1
    fi
}

install_binary_packages () {
    echo "Installing binary packages"
    cd /tmp || exit
    for ext in tgz txz; do
	echo "Processing extension: $ext"
        wget -v -c -nc -r -np -l1 -P ./ -nd "${BASEURL}" -A ${ext}  | tee -a $LOG_FILE
        for a in *.${ext}; do
	    echo "Processing: $a"
            upgradepkg --install-new $a;  | tee -a $LOG_FILE
        done
    done
}

install_with_slpkg_compile () {
    rm -f /var/log/slpkg.log
    slpkg update >> /var/log/slpkg.log
    for pkg in "${PKG[*]}"; do
	    pm "Installing (with slpkg): $pkg"
	    slpkg -s sbo "$pkg" --rebuild >> /var/log/slpkg.log
    done
}

aux_slbuild () {
    cd /tmp
    wget "$1"
    wget "$2"
    slname="$(basename $1)"
    pkgname="$(basename $2)"
    slpkg -a "$slname" "$pkgname"
    unset $VERSION
}

install_from_source_new_version () {
    export VERSION=6.1.0
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/academic/octave.tar.gz  https://mirror.cedia.org.ec/gnu/octave/octave-6.1.0.tar.lz
}

install_latest_firefox() {
    MSG="Installing latest firefox ..."
    pm "$MSG"
    sleep 2
    if [ x"" != x"$(firefox --version | grep esr)" ]; then
	    cd || exit
	    if [ ! -d $HOME/repos/ ]; then
	        mkdir -p $HOME/repos
	    fi
	    cd $HOME/repos || exit
	    if [ ! -d computer-labs ]; then
	        git clone https://github.com/iluvatar1/computer-labs
	    fi
	    cd computer-labs || exit
	    bash packages/latest-firefox.sh -i
	    pm "Done"
    else
	    pm "Already installed: $(firefox --version)"
    fi
}

install_perf () {
    MSG="Installing perf ..."
    pm "$MSG"
    sleep 2
    if ! hash perf 2>/dev/null; then
	    cd /usr/src/linux/tools/perf || exit
	    VERSION=$(uname -r) make -j 2 prefix=/usr/local install
	    pm "Done"
    else
	    pm "Already installed"
    fi
}



################################################################################
# MAIN

# install other packages not from mirror
if [ "NO" = "$MIRROR_ONLY" ]; then  
    source $HOME/.bashrc
    setup
    echo "install qt5 and other deps from slack"
    #slpkg -s slack qt5 icu4c lz4 tigervnc
    slpkg -s bash-completion tigervnc xf86-video-nouveau-blacklist | tee -a $LOG_FILE

    echo "Install clustershell"
    pip3 install clustershell | tee -a $LOG_FILE
    #install_latest_firefox
    #install_perf
    echo "install some big packages already compiled by alien: libreoffice inkscape vlc popplerc-compat"
    slpkg -s alien libreoffice inkscape vlc poppler-compat  | tee -a $LOG_FILE
fi

if [ "NO" = "$COMPILE" ]; then
    install_binary_packages
else
    install_with_slpkg_compile
fi

# Configure x2go to avoid using compositing with xfce4
TNAME=/etc/x2go/xinitrc.d/xfwm4_no_compositing
if [ ! -f $TNAME ]; then
    echo "/usr/bin/xfconf-query -c xfwm4 -p /general/use_compositing -s false" > $TNAME
fi
if [ ! -x $TNAME ]; then
    chmod +x $TNAME
fi

# remove already installed packages
rm -f /tmp/*tgz 2>/dev/null
