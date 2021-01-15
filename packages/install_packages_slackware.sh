# list of packages to install (common mainly by name)
if [ "$1" != "BASIC" ] && [ "$1" != "MISC" ] && [ "$1" != "NUMERIC" ] && [ "$1" != "EXTRA" ] && [ "$1" != "SALAFIS" ]; then
    echo "Error. Call this script as :"
    echo "$0 [BASIC|NUMERIC|MISC|EXTRA|SALAFIS]"
    exit 1
fi

# fix PATH to remove anaconda stuff
export PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/games:/usr/lib64/kde4/libexec:/usr/lib64/qt/bin:/usr/share/texmf/bin

# use slpkg
source /root/.bashrc
slpkg upgrade
#SLPKG_CMD="slpkg -s sbo"

# Setup packages
PKG=
SRC=
if [ "$1" == "BASIC" ]; then
    PKG="keepassx sshfs-fuse autossh xfce4-xkb-plugin flashplayer-plugin slim monit fail2ban corkscrew pip parallel wol valgrind openmpi modules cppcheck iotop gperftools"
elif [ "$1" == "NUMERIC" ]; then
    PKG="fltk netcdf arpack blas atlas hdf5 lapack suitsparse armadillo octave R rstudio-desktop"    
elif [ "$1" == "MISC" ]; then
    PKG="valkyrie grace djview4 lame kile kdenlive dropbox pdftk filezilla scribus povray ninja chromium smplayer vlc inkscape ffmpeg audacity graphviz libticonv gocr msmtp lyx  wine eagle skype twolame mplayer-codecs32 flashplayer-plugin pyserial dfc acpica virtualbox-kernel virtualbox-kernel-addons virtualbox-extension-pack  PyYAML ntpclient  proxychains proxytunnel libreoffice"
elif [ "$1" == "EXTRA" ]; then
    PKG="GoogleEarth blender QtiPlot scidavis"
elif [ "$1" == "SALAFIS" ]; then
    PKG="arduino geany kdiff3"
fi

for pkgname in $PKG; do
    $SLPKG_CMD $pkgname
    if [ "$?" != "0" ]; then
	echo "# Error installing package -> $pkgname"
    fi
done
		   

################################################################################
COMPILE=${COMPILE:-NO}
PKG="keepassx sshfs-fuse autossh xfce4-xkb-plugin flashplayer-plugin slim monit fail2ban corkscrew pip parallel wol valgrind openmpi modules cppcheck iotop gperftools"

pm () {
    echo "  -> $1"
}

setup () {
    if hash slpkg &> /dev/null; then
        pm "Updating slpkg ..."
        slpkg upgrade
    else
        pm "ERROR: slpkg not installed. Exiting"
        exit 1
    fi
}

install_binary_packages () {
    BASEURL="http://157.245.132.188/PACKAGES/slackware64-current/"
    cd /tmp || exit
    rm -f "PACKAGES.txt" 2>/dev/null
    wget -c -nc "$BASEURL/PACKAGES.txt" 2> /dev/null
    while read -r line; do
	pm "Installing (from binary): $line"
	bname=${line%.*}
	pm "  basename: $bname"
	if [ ! -e "/var/log/packages/$bname" ]; then
	    wget -c -nc "$BASEURL/$line"
	    installpkg "$line"
	else
	    pm "Already installed: $line"
	fi
    done < PACKAGES.txt
}

install_with_slpkg_compile () {
    rm -f /var/log/slpkg.log
    slpkg update >> /var/log/slpkg.log
    for pkg in "${PKG[@]}"; do
	    pm "Installing (with slpkg): $pkg"
	    slpkg -s sbo "$pkg" >> /var/log/slpkg.log
    done
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

install_spack () {
    MSG="Installing Spack"
    pm "$MSG"
    sleep 2
    if [ ! -d /home/live/repos/spack ]; then
	    mkdir -p /home/live/repos/
	    cd /home/live/repos/ || exit 1
	    git clone https://github.com/spack/spack
	    echo "source /home/live/repos/spack/share/spack/setup-env.sh" >> /home/live/.bashrc
	    chown -R live /home/live/repos /home/live/.bashrc
	    pm "Done"
    else
	    pm "Already installed"
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

setup

if [ "NO" == "$COMPILE" ]; then
    install_binary_packages
else
    install_with_slpkg_compile
fi

#install_latest_firefox
install_spack
install_perf
# install some big packages already compiled by alien
slpkg -s alien libreoffice inkscape vlc poppler-compat
