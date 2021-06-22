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

    PKGS=(blas lapack keepassx  autossh slim fail2ban corkscrew
    valgrind modules cppcheck iotop xdm-slackware-theme  uuid
    mongo-c-driver PyYAML arno-iptables-firewall cntlm confuse
    rrdtool numactl vscode-bin wol flashplayer-plugin gperftools
    keepassxc perl-Capture-Tiny perl-Config-Simple perl-DBD-SQLite
    perl-File-ReadBackwards perl-File-Which perl-IPC-System-Simple
    perl-Module-Build perl-PAR-Dist perl-Switch perl-Try-Tiny
    perl-Unix-Syslog perl-file-basedir pip xfce4-xkb-plugin)

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
    groupadd -g 290 x2gouser
    useradd -u 290 -g 290 -c "X2Go Remote Desktop" -M -d /var/lib/x2go -s /bin/false x2gouser
    groupadd -g 291 x2goprint
    mkdir -p /var/spool/x2goprint &>/dev/null
    useradd -u 291 -g 291 -c "X2Go Remote Desktop" -m -d /var/spool/x2goprint -s /bin/false x2goprint
    chown x2goprint:x2goprint /var/spool/x2goprint
    chmod 0770 /var/spool/x2goprint
    wget https://slackbuilds.org/slackbuilds/14.2/network/x2goserver.tar.gz
    wget http://ponce.cc/slackware/sources/repo/x2goserver-20201227_08aa5e6.tar.xz
    VERSION=20201227_08aa5e6 slpkg -a x2goserver.tar.gz x2goserver-20201227_08aa5e6.tar.xz
    echo "/usr/bin/xfconf-query -c xfwm4 -p /general/use_compositing -s false" > /etc/x2go/xinitrc.d/xfwm4_no_compositing
    chmod +x /etc/x2go/xinitrc.d/xfwm4_no_compositing
    #slpkg -s sbo x2goserver
    # tigervnc for vnc
    #slackpkg install tigervnc
    # ganglia
    export OPT=gmetad
    $SLPKG ganglia ganglia-web
    unset OPT
    # monit
    export VERSION=5.28.0
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/system/monit.tar.gz https://mmonit.com/monit/dist/monit-5.28.0.tar.gz
    unset VERSION
    # octave
    export VERSION=6.1.0
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/academic/octave.tar.gz  https://mirror.cedia.org.ec/gnu/octave/octave-6.1.0.tar.lz
    unset VERSION
    # HPC: munge
    export VERSION=0.5.14
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/network/munge.tar.gz https://github.com/dun/munge/releases/download/munge-0.5.14/munge-0.5.14.tar.xz
    unset VERSION
    # HPC: hwloc
    export VERSION=2.3.0
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/system/hwloc.tar.gz https://download.open-mpi.org/release/hwloc/v2.3/hwloc-2.3.0.tar.bz2
    unset VERSION
    # HPC: slurm
    groupadd -g 311 slurm
    useradd -u 311 -d /var/lib/slurm -s /bin/false -g slurm slurm
    export VERSION=20.11.2
    export HWLOC=yes
    export RRDTOOL=yes
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/network/slurm.tar.gz https://download.schedmd.com/slurm/slurm-20.11.2.tar.bz2
    unset VERSION HWLOC RRDTOOL
    # HPC: openmpi
    export VERSION=4.1.0
    export PMI=yes
    aux_slbuild https://slackbuilds.org/slackbuilds/14.2/system/openmpi.tar.gz https://download.open-mpi.org/release/open-mpi/v4.1/openmpi-4.1.0.tar.bz2
    unset VERSION PMI
    # netdata
    groupadd -g 338 netdata 2>/dev/null
    useradd -u 338 -g 338 -c "netdata user" -s /bin/bash netdata 2>/dev/null
    cd /tmp
    wget https://slackbuilds.org/slackbuilds/14.2/system/netdata.tar.gz &&
        wget https://github.com/netdata/netdata/archive/v1.29.3/netdata-1.29.3.tar.gz &&
        tar xf netdata.tar.gz &&
        mv netdata/netdata.SlackBuild{,-orig} &&
        cp $HOME/repos/computer-labs/computer-room/files/netdata.SlackBuild netdata/ &&
        chmod +x netdata/netdata.SlackBuild &&
        tar czf netdata.tar.gz netdata &&
        slpkg -a netdata.tar.gz netdata-1.29.3.tar.gz &&
        chmod +x /etc/rc.d/rc.netdata
}



##############################
# MAIN
#############################
cd /tmp
rm -f *tgz *txz

# build packages
pm "Building packages ..."
build_packages

# read auth config: USER, PASSWD, IP. YOU WILL HAVE TO COPY THE PUBLIC KEY
echo "Do not forget to copy the public id into the server"
LOCALUSER=${LOCALUSER:-oquendo}
IP=${IP:-localhost}

# upload both packages and PACKAGES.txt
pm "Sending packages ..."
cd /tmp
mkdir PACKAGES 2>/dev/null
mv *tgz PACKAGES/
cd PACKAGES
for a in *tgz; do
    pm "$a ..."
    rsync -e 'ssh -o StrictHostKeyChecking=no' -av $a $LOCALUSER@$IP:/var/www/html/PACKAGES/slackware64-current/$a
done
