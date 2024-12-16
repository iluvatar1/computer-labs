#!/bin/bash
#####################################
# COPY patch to /tmp
# slurm
WGET="wget --no-check-certificate -c -nc"
cd /tmp
TDIR=/var/lib/sbopkg/SBo-git/
SLURM_VERSION=20.11.9
FNAME=slurm-$SLURM_VERSION.tar.bz2
$WGET https://download.schedmd.com/slurm/$FNAME -O $TDIR/network/slurm/$FNAME
cd $TDIR/network/slurm || exit 1
if ! grep -q PMIX_SUPPORT slurm.SlackBuild; then
	cp slurm.SlackBuild{,.bck}
	patch slurm.SlackBuild < /tmp/slurm_pmix.patch || exit 1
fi
echo "Fixing rrdtool const char problem"
sed -i.bck '161s/const //' /usr/include/rrd.h
MAKEFLAGS="-j$(nproc)" VERSION=$SLURM_VERSION HWLOC=yes RRDTOOL=yes PMIX=yes bash slurm.SlackBuild || exit 1
upgradepkg --install-new --reinstall /tmp/slurm*.tgz || exit 1
echo "Slurm $SLURM_VERSION installed"