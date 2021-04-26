#!/usr/bin/env bash
set -euo pipefail

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
    SLPKG="slpkg -s sbo --rebuild"
    $SLPKG keepassx sshfs-fuse autossh xfce4-xkb-plugin flashplayer-plugin slim monit fail2ban corkscrew pip parallel wol valgrind openmpi modules cppcheck iotop xdm-slackware-theme
    $SLPKG libuv uuid mongo-c-driver PyYAML arno-iptables-firewall monit cntlm x2goserver confuse rrdtool numactl valkyrie
    export OPT=gmetad
    $SLPKG ganglia ganglia-web
    unset OPT
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
build_packages

# create PACKAGES.txt file
ls *tgz *txz > PACKAGES.txt

# read auth config: USER, PASSWD, IP
source AUTH.txt

# upload both packages and PACKAGES.txt
for a in *tgz *txz PACKAGES.txt; do
    rsync -e 'ssh ' -av $a $USER:$PASSWD@$IP:/var/www/html/PACKAGES/slackware64-current/$a
done
