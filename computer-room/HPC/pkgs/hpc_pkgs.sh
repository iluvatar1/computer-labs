#!/usr/bin/env bash
#set -euo pipefail

CURRENT_DIR=$PWD

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
    echo
    ColorGreen "#----------------------- "
    ColorCyan "$1"
}

QUEUE_NAME=custom_hpc
QUEUE_PATH=/var/lib/sbopkg/queues/${QUEUE_NAME}.sqf

build_packages_sbo () {
    # create queue
    cat <<EOF > $QUEUE_PATH
    modules
    munge 
    confuse
    ganglia | OPT=gmetad MAKEFLAGS="-j$(nproc)" CPPFLAGS=-I/usr/include/tirpc/ LDFLAGS=-ltirpc
    ganglia-web | OPT=gmetad MAKEFLAGS="-j$(nproc)" CPPFLAGS=-I/usr/include/tirpc/ LDFLAGS=-ltirpc   
    numactl
    rrdtool
EOF

    #####################################
    # Download and fix particular versions
    cd /tmp
    TDIR=/var/lib/sbopkg/SBo-git/
    WGET="wget -c "

    #####################################
    pm "Updating sbo package database ..."
    sbopkg -r

    #####################################
    #####################################
    pm "Pre-configurations and downloads ..."

    #####################################
    pm "Build and install queue ${QUEUE_NAME}..."
    if ! grep -q nproc /etc/sbopkg/sbopkg.conf; then
        echo 'export MAKEOPTS="-j$(nproc)"' >> /etc/sbopkg/sbopkg.conf
        echo 'export MAKEFLAGS="-j$(nproc)"' >> /etc/sbopkg/sbopkg.conf
    fi
    printf "Q\nQ\n" | MAKEFLAGS="-j$(nproc)" sbopkg -e continue -B -k -i $QUEUE_NAME # WARNING: Add Q\n for each package with options
    # ganglia: fixes old rpc with new libtirpc
    #printf "C\nP\n" | MAKEFLAGS="-j$(nproc)" CPPFLAGS=-I/usr/include/tirpc/ LDFLAGS=-ltirpc sbopkg -k -i ganglia:OPT=gmetad
    #printf "C\nP\n" | MAKEFLAGS="-j$(nproc)" CPPFLAGS=-I/usr/include/tirpc/ LDFLAGS=-ltirpc sbopkg -k -i ganglia-web:OPT=gmetad

    #####################################
    # 2024-05-09: TODO update to 2.9.3
    pm "-> hwloc (removing opencl) ..."
    if ! hash hwloc-info 2>/dev/null; then
	#FNAME=hwloc-2.7.0.tar.gz
	FNAME=hwloc-2.7.0.tar.bz2
	if [[ ! -f $TDIR/system/hwloc/$FNAME ]] ; then 
	    $WGET https://download.open-mpi.org/release/hwloc/v2.7/$FNAME -O $TDIR/system/hwloc/$FNAME
	fi
	if ! grep -q "disable-opencl" $TDIR/system/hwloc/hwloc.SlackBuild  ; then 
	    #sed -i.bck 's/--disable-debug /--disable-debug --disable-opencl --disable-openmpi /' $TDIR/system/hwloc/hwloc.SlackBuild # not needed to disable openmpi
	    sed -i.bck 's/--disable-debug /--disable-debug --disable-opencl /' $TDIR/system/hwloc/hwloc.SlackBuild
	    sed -i.bck2 's/--enable-netloc /#--enable-netloc /' $TDIR/system/hwloc/hwloc.SlackBuild
	fi
	cd $TDIR/system/hwloc
	MAKEFLAGS="-j$(nproc)" VERSION=2.7.0 bash hwloc.SlackBuild
	upgradepkg --install-new --reinstall /tmp/hwloc*tgz	
	cd $CURRENT_DIR
    else
	echo "Already installed"
    fi

    
    #####################################
    #####################################
    pm "Post-queue installs and configurations ..."

    #####################################
    # This will not work now, I need to download it from the slackbuild repo
    # pmix prereq for slurm
    pm "-> openmpix (version 3.2.3, larger versions are not supported by slurm 20.11.8 as of 2022-02-08)"
    if ! hash pmix_info 2>/dev/null; then
	cd $CURRENT_DIR
	cd pmix
	$WGET https://github.com/openpmix/openpmix/releases/download/v3.2.3/pmix-3.2.3.tar.bz2
	VERSION=3.2.3 MAKEFLAGS="-j$(nproc)" bash pmix.SlackBuild
	upgradepkg --install-new --reinstall /tmp/*pmix*tgz
	cd $CURRENT_DIR
    else
	echo "Already installed"
    fi    

    
    #####################################
    # slurm
    # TODO: Make idempotent
    #pm "-> Fix slurm since version option is not read ( pmix support detected automatically) ..."
    pm "-> Fix slurm since version option is not read ( pmix support added explicitly) ..."
    if ! hash slurmd 2>/dev/null; then
	export SLURMUSER=992
	if ! id -g slurm &>/dev/null; then 
	    groupadd -g $SLURMUSER slurm
	fi
	if ! id -u slurm &>/dev/null; then 
	    useradd  -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm  -s /bin/bash slurm
	fi
	SLURM_VERSION=20.11.9
	FNAME=slurm-$SLURM_VERSION.tar.bz2
	$WGET https://download.schedmd.com/slurm/$FNAME -O $TDIR/network/slurm/$FNAME
    	cd $TDIR/network/slurm
	if ! grep -q PMIX_SUPPORT slurm.SlackBuild; then
	    cp slurm.SlackBuild{,.bck}
	    patch slurm.SlackBuild < $CURRENT_DIR/slurm_pmix.patch
	fi
      	MAKEFLAGS="-j$(nproc)" VERSION=$SLURM_VERSION HWLOC=yes RRDTOOL=yes PMIX=yes bash slurm.SlackBuild
	upgradepkg --install-new --reinstall /tmp/slurm*.tgz
	cd $CURRENT_DIR
    else
	echo "Already installed"
    fi

    #####################################
    # openmpi
    pm "-> Installing openmpi with pmi support for slurm"
    if ! hash mpirun 2>/dev/null; then
	FNAME=openmpi-4.1.2.tar.bz2
	if [ ! -f $TDIR/system/openmpi/$FNAME ]; then
	    $WGET https://download.open-mpi.org/release/open-mpi/v4.1/$FNAME -O $TDIR/system/openmpi/$FNAME
	fi
	cd $TDIR/system/openmpi
	if ! grep -q "--with-pmix=/usr/local" openmpi.SlackBuild; then
	    cp openmpi.SlackBuild{,.bck}
	    patch openmpi.SlackBuild < $CURRENT_DIR/openmpi_pmix.patch
	fi
      	MAKEFLAGS="-j$(nproc)" VERSION=4.1.2 PMI=yes bash openmpi.SlackBuild
	upgradepkg --install-new --reinstall /tmp/openmpi*tgz	
    else
	echo "Already installed"
    fi
}

##############################
# MAIN
#############################
cd /tmp
#rm -f *tgz *txz

# build packages
pm "Building packages ..."
build_packages_sbo

pm "DONE."
