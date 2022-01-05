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

build_packages_sbo () {
    # create queue
    cat <<EOF > /var/lib/sbopkg/queues/custom.sqf
    blas
    lapack
    monit | VERSION=5.29.0
    autossh
    slim
    fail2ban
    corkscrew
    sshpass
    iotop
    xdm-slackware-theme
    uuid
    mongo-c-driver
    arno-iptables-firewall
    cntlm
    rrdtool
    udpcast
    vscode-bin
    wol
    kitty
    bat
    keepassxc
    perl-Switch
    perl-IPC-System-Simple
    perl-PAR-Dist
    perl-Module-Build
    perl-File-Which
    perl-file-basedir
    perl-Unix-Syslog
    perl-Try-Tiny
    perl-Capture-Tiny
    perl-DBD-SQLite
    perl-File-ReadBackwards
    perl-Config-Simple
    nx-libs
    x2goserver
    xfce4-xkb-plugin
    netdata
    munge 
    confuse
    ganglia | OPT=gmetad
    ganglia-web | OPT=gmetad    
    hwloc
    numactl
    rrdtool
    #slurm | VERSION=20.11.8 HWLOC=yes RRDTOOL=yes NUMA=yes
EOF
    #####################################
    # Download and fix particular versions
    cd /tmp
    TDIR=/var/lib/sbopkg/SBo-git/
    WGET="wget -c "
    # x2goserver prerequisites
    groupadd -g 290 x2gouser
    useradd -u 290 -g 290 -c "X2Go Remote Desktop" -M -d /var/lib/x2go -s /bin/false x2gouser
    groupadd -g 291 x2goprint
    mkdir -p /var/spool/x2goprint &>/dev/null
    useradd -u 291 -g 291 -c "X2Go Remote Desktop" -m -d /var/spool/x2goprint -s /bin/false x2goprint
    chown x2goprint:x2goprint /var/spool/x2goprint
    chmod 0770 /var/spool/x2goprint
    # monit
    sed -i.bck 's/ README//' /var/lib/sbopkg/SBo-git/system/monit/monit.SlackBuild
    FNAME=monit-5.29.0.tar.gz
    $WGET https://mmonit.com/monit/dist/$FNAME -O $TDIR/system/monit/$FNAME
    #####################################
    # build and install queue
    if ! grep -q nproc /etc/sbopkg/sbopkg.conf; then
        echo 'export MAKEOPTS="-j$(nproc)"' >> /etc/sbopkg/sbopkg.conf
        echo 'export MAKEFLAGS="-j$(nproc)"' >> /etc/sbopkg/sbopkg.conf
    fi
    printf "Q\nQ\nQ\n" | MAKEFLAGS="-j$(nproc)" sbopkg -B -k -i custom # WARNING: Add Q\n for each package with options
    # ganglia: fixes old rpc with new libtirpc
    #printf "C\nP\n" | MAKEFLAGS="-j$(nproc)" CPPFLAGS=-I/usr/include/tirpc/ LDFLAGS=-ltirpc sbopkg -k -i ganglia:OPT=gmetad
    #printf "C\nP\n" | MAKEFLAGS="-j$(nproc)" CPPFLAGS=-I/usr/include/tirpc/ LDFLAGS=-ltirpc sbopkg -k -i ganglia-web:OPT=gmetad
    # slurm
    # TODO Fix slurm since version option is not read
    if ! hash slurmd 2>/dev/null; then
	groupadd -g 311 slurm
	useradd -u 311 -d /var/lib/slurm -s /bin/false -g slurm slurm
	FNAME=slurm-20.11.8.tar.bz2
	$WGET https://download.schedmd.com/slurm/$FNAME -O $TDIR/network/slurm/$FNAME
    	cd $TDIR/network/slurm
      	MAKEFLAGS="-j$(nproc)" VERSION=20.11.8 HWLOC=yes RRDTOOL=yes bash slurm.SlackBuild
	installpkg /tmp/slurm-20.11.8-x86_64-1_SBo.tgz
    fi
    #####################################
    # netdata
    # if ! hash netdata 2>/dev/null; then
    # 	groupadd -g 338 netdata 2>/dev/null
    # 	useradd -u 338 -g 338 -c "netdata user" -s /bin/bash netdata 2>/dev/null
    # 	cd /tmp
    # 	$WGET https://slackbuilds.org/slackbuilds/14.2/system/netdata.tar.gz &&
    #         $WGET https://github.com/netdata/netdata/archive/v1.29.3/netdata-1.29.3.tar.gz &&
    #         tar xf netdata.tar.gz &&
    #         mv netdata/netdata.SlackBuild{,-orig} &&
    #         cp $HOME/repos/computer-labs/computer-room/files/netdata.SlackBuild netdata/ &&
    #         chmod +x netdata/netdata.SlackBuild &&
    #         tar czf netdata.tar.gz netdata &&
    #         slpkg -a netdata.tar.gz netdata-1.29.3.tar.gz &&
    #         chmod +x /etc/rc.d/rc.netdata
    # fi
}

##############################
# MAIN
#############################
cd /tmp
#rm -f *tgz *txz

# build packages
pm "Building packages ..."
build_packages_sbo

# read auth config: USER, PASSWD, IP. YOU WILL HAVE TO COPY THE PUBLIC KEY for passwordless
echo "Do not forget to copy the public id into the server"
USERNAME=${USERNAME:-oquendo}
IP=${IP:-127.0.0.1}
PASSWORD=${PASSWORD:-NULL}
PORT=${PORT:-22}

######################
# echo "Generating key ..."
# ssh-keygen -t rsa -f /root/.ssh/id_rsa -q -N ""
# echo "Copying the id using sshpass and ssh-copy-id ..."
# sshpass -f $TMPFNAME ssh-copy-id -p $PORT -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $USERNAME@$IP

pm "Installing needed packages to setup ssh ..."
sbopkg -k -i corkscrew
sbopkg -k -i sshpass
pm "Saving password in temp file ..."
TMPFNAME=$(mktemp)
echo $PASSWORD > $TMPFNAME
pm "Setting up proxy if needed ..."
if [ ! -z https_proxy ]; then
    FULLPROXY=$(echo $https_proxy | tr -d '/')
    FULLPROXY=${FULLPROXY#http:}
    PROXY=${FULLPROXY%:*}
    PROXYPORT=${FULLPROXY#*:}
    echo "ProxyCommand /usr/bin/corkscrew $PROXY $PROXYPORT %h %p" > $HOME/.ssh/config
fi
pm "Sending packages ..."
cd /tmp
mkdir PACKAGES 2>/dev/null
mv *tgz PACKAGES/ 2>/dev/null
rsync --delete -e 'sshpass -f '$TMPFNAME' ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p '$PORT' ' -av PACKAGES/ $USERNAME@$IP:/var/www/html/PACKAGES/slackware64-current/
pm "Removing password file ..."
rm -f $TMPFNAME

pm "DONE."
######################## PACKAGES FOR SPACK
# valgrind
# lmod
# cppcheck
# numactl
# iperf3
# gperftools
# keepassxc
# kitty
# bat
# libconfuse
# munge
# hwloc
# openmpi
# slurm
# netdata
# ganglia
