echo "EXECUTING SCRIPT : packages.sh"

#fix apt slow mirrors
if [ "" == "$(grep edatel /etc/apt/sources.list | grep -v grep)" ]; then
    mv /etc/apt/sources.list /etc/apt/sources.list.old
    cat <<EOF >> /etc/apt/sources.list
    deb http://mirrors.advancedhosters.com/linuxmint/packages rosa main upstream import
    deb http://extra.linuxmint.com rosa main
    deb http://mirror.edatel.net.co/ubuntu trusty main restricted universe multiverse
    deb http://mirror.edatel.net.co/ubuntu trusty-updates main restricted universe multiverse
    deb http://security.ubuntu.com/ubuntu/ trusty-security main restricted universe multiverse
    deb http://archive.canonical.com/ubuntu/ trusty partner
EOF
fi

# Configure fancy progress in apt
#if [ ! -f /etc/apt/apt.conf ] || [ "" == "$(grep Progress-Fancy /etc/apt/apt.conf | grep -v grep)" ]; then
#echo 'Dpkg::Progress-Fancy "1";' >> /etc/apt/apt.conf
#fi

echo "Fixing missing"
apt-get update --fix-missing -y &> /dev/null 
echo "Upgrading packages"
#apt-get -y upgrade

# NOTE: for lmgc90, python-numpy should be used (version 1.8.x) since lmgc90 does not support higher versions
PACKAGES=(git python-pip build-essential m4 gfortran libncurses5-dev libigraph0-dev make cmake cmake-curses-gui libvtk6-dev libeigen2-dev libeigen3-dev libopenmpi-dev g++ git-core openmpi-common openmpi-bin libopenmpi-dev mercurial htop paraview fftw-dev python-dev libpython-dev  python-numpy python-scipy python-matplotlib libatlas-dev libblas-dev liblapack-dev tcl-vtk6 python-vtk6 swig doxygen python-sphinx subversion libmetis5 libmetis5-dbg libscotch-dev wget patch libgsl0-dev libsuitesparse-dev libboost-python-dev python-tk libmumps-dev libparmetis-dev libgtk-3-dev libfltk1.3-dev libxml2-dev libcgal-dev libhdf5-serial-dev libhdf5-dev libcgal-dev libboost-dev libxres-dev ipython-notebook ntp chromium-browser ispell aspell sox emacs eterm rxvt tmux)
# texlive)
echo "Installing the following packages : ${PACKAGES[@]} ..."
# make a list of installed packages
dpkg -l > /tmp/pkglist
for a in ${PACKAGES[@]}; do
    echo "Processing package : $a"
    #VAL=$(dpkg -l $a | tail -n 1 | awk '{print ($1 == "ii")}')
    #dpkg-query -W -f='${Status} ${Version}\n' $a &> /dev/null
    status=$(grep $a /tmp/pkglist | grep -v grep)
    if [ "" == "$status" ]; then 
	printf "\nINSTALLING : $a"
	apt-get install -y $a &>> /var/log/log-install-packs
	printf "Installation STATUS: $?\n\n"
    fi
done

echo "Removing not needed packages "
apt-get -y autoremove


# Fix some errors with dictionaries 
##apt-get install -y  ${PACKAGES[@]} > /dev/null
#apt-get remove -y dictionaries-common >> install-log
#apt-get install --reinstall -y dictionaries-common >> install-log
#apt-get update --fix-missing -y &> /dev/null
#dpkg --configure -a
##apt-get install -y  ${PACKAGES[@]} > /dev/null


# gui
#echo "Installing xfce4 gui and ldm ..."
#apt-get install -y xfce4
#apt-get install -y lxdm virtualbox-guest-dkms virtualbox-guest-utils virtualbox-guest-x11 virtualbox-guest-additions-iso dkms 
#dpkg-reconfigure lxdm

# python specific
#PACKAGES=(scipy matplotlib jupyter)
#echo "Installing the following python packages with pip : ${PACKAGES[@]} ..."
#pip install ${PACKAGE[@]} > /dev/null

echo "Done."
