#!/bin/bash
#####################################
# openmpi
cd /tmp
TDIR=/var/lib/sbopkg/SBo-git/
WGET="wget --no-check-certificate -c -nc"

echo "-> Installing openmpi with pmi support for slurm"
if ! hash mpirun 2>/dev/null; then
    echo "openmpi not installed"
    FNAME=openmpi-4.1.2.tar.bz2
    if [ ! -f $TDIR/system/openmpi/$FNAME ]; then
        $WGET https://download.open-mpi.org/release/open-mpi/v4.1/$FNAME -O $TDIR/system/openmpi/$FNAME
    fi
    cd $TDIR/system/openmpi || exit 1
    echo "Fix pmix support"
    # replace
    # pmi="" ; [ "${PMI:-no}" != "no" ]  && pmi="--with-slurm --with-pmix"
    # with
    # pmi="" ; [ "${PMI:-no}" != "no" ]  && pmi="--with-slurm --with-pmix=/usr/local --with-pmix-libdir=/usr/local/lib --with-pmi=/usr/local --with-pmi-libdir=/usr/local/lib"
    sed -i.bck 's/--with-slurm --with-pmix/--with-slurm --with-pmix=\/usr\/local --with-pmix-libdir=\/usr\/local\/lib --with-pmi=\/usr\/local --with-pmi-libdir=\/usr\/local\/lib/' openmpi.SlackBuild
    echo "Compiling openmpi"
    MAKEFLAGS="-j$(nproc)" VERSION=4.1.2 PMI=yes bash openmpi.SlackBuild || exit 1
    upgradepkg --install-new --reinstall /tmp/openmpi*tgz	
else
    echo "Already installed"
fi