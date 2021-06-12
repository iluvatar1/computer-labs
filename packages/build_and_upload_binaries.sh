#!/usr/bin/env bash
#set -euo pipefail

##
# Color  Variables
##
red='\e[31m'
green='\e[32m'
yellow='\e[33m'
blue='\e[34m'
magenta='\e[35m'
cyan='\e[36m'
lred='\e[91m'
lgreen='\e[92m'
lyellow='\e[93m'
lblue='\e[94m'
lmagenta='\e[95m'
lcyan='\e[96m'
white='\e[97m'
clear='\e[0m'

##
# Color Functions
##

ColorGreen(){
	echo -e $green$1$clear
}
ColorLGreen(){
	echo -e $lgreen$1$clear
}
ColorBlue(){
	echo -e $blue$1$clear
}
ColorCyan(){
	echo -e $cyan$1$clear
}
ColorYellow(){
	echo -e $yellow$1$clear
}


pm () {
    ColorGreen "  -> "
    ColorCyan "$1"
}

setup () {
    if hash slpkg &> /dev/null; then
        pm "Updating slpkg ..."
        source /root/.bashrc
        slpkg upgrade
    else
        pm "ERROR: slpkg not installed. Exiting"
        exit 1
    fi
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

build_packages () {
    # fix slpkg downgrade checking with no installed version. Fixes authossh and nx-libs
    sed -i.bck 's/ins_ver = "0"/return False/' /usr/lib64/python3.9/site-packages/slpkg/sbo/slackbuild.py

    # Define SLPKG command
    SLPKG="slpkg -s sbo --rebuild"

    PKGS=(blas lapack keepassx sshfs-fuse autossh slim fail2ban corkscrew
    valgrind modules cppcheck iotop xdm-slackware-theme libuv uuid
    mongo-c-driver PyYAML arno-iptables-firewall cntlm confuse
    rrdtool numactl vscode-bin wol)

    for pkgname in ${PKGS[*]}; do
        echo $pkgname
        $SLPKG $pkgname
    done
    # Particular builds
    # nx-libs lite
    wget https://slackbuilds.org/slackbuilds/14.2/libraries/nx-libs.tar.gz
    wget https://code.x2go.org/releases/source/nx-libs/nx-libs-3.5.99.22-lite.tar.gz -O nx-libs-3.5.99.22-full.tar.gz
    VERSION=3.5.99.22 slpkg -a nx-libs.tar.gz nx-libs-3.5.99.22-full.tar.gz
    # x2go
    wget https://slackbuilds.org/slackbuilds/14.2/network/x2goserver.tar.gz
    wget http://ponce.cc/slackware/sources/repo/x2goserver-20201227_08aa5e6.tar.xz
    VERSION=20201227_08aa5e6 slpkg -a x2goserver.tar.gz x2goserver-20201227_08aa5e6.tar.xz
    echo "/usr/bin/xfconf-query -c xfwm4 -p /general/use_compositing -s false" > /etc/x2go/xinitrc.d/xfwm4_no_compositing
    chmod +x /etc/x2go/xinitrc.d/xfwm4_no_compositing
    #slpkg -s sbo x2goserver
    # tigervnc for vnc
    slackpkg install tigervnc
    #
    export OPT=gmetad
    $SLPKG ganglia ganglia-web
    unset OPT
    export VERSION=5.28.0
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/system/monit.tar.gz https://mmonit.com/monit/dist/monit-5.28.0.tar.gz
    unset VERSION
    export VERSION=6.1.0
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/academic/octave.tar.gz  https://mirror.cedia.org.ec/gnu/octave/octave-6.1.0.tar.lz
    unset VERSION
    # HPC
    export VERSION=0.5.14
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/network/munge.tar.gz https://github.com/dun/munge/releases/download/munge-0.5.14/munge-0.5.14.tar.xz
    unset VERSION
    export VERSION=2.3.0
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/system/hwloc.tar.gz https://download.open-mpi.org/release/hwloc/v2.3/hwloc-2.3.0.tar.bz2
    unset VERSION
    groupadd -g 311 slurm
    useradd -u 311 -d /var/lib/slurm -s /bin/false -g slurm slurm
    export VERSION=20.11.2
    export HWLOC=yes
    export RRDTOOL=yes
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/network/slurm.tar.gz https://download.schedmd.com/slurm/slurm-20.11.2.tar.bz2
    unset VERSION HWLOC RRDTOOL
    export VERSION=4.1.0
    export PMI=yes
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/system/openmpi.tar.gz https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.0.tar.bz2
    unset VERSION PMI
}



##############################
# MAIN
#############################
cd /tmp
rm -f *tgz *txz

# build packages
pm "Building packages ..."
build_packages

# create PACKAGES.txt file
pm "Getting the built packages list ..."
ls *tgz *txz > PACKAGES.txt 2> /dev/null

# read auth config: USER, PASSWD, IP. YOU WILL HAVE TO COPY THE PUBLIC KEY
echo "Do not forget to copy the public id into the server"
USER=${USER:-oquendo}
IP=${IP:-localhost}

# upload both packages and PACKAGES.txt
pm "Sending packages ..."
for a in *tgz *txz PACKAGES.txt; do
    pm "$a ..."
    rsync -e 'ssh -o StrictHostKeyChecking=no' -av $a $USER@$IP:/var/www/html/PACKAGES/slackware64-current/$a
done
