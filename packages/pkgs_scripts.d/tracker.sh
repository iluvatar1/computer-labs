#!/bin/bash

PKGDIR=/tmp/tracker

if [[ ! -d $PKGDIR ]]; then
    mkdir $PKGDIR
fi

BDIR=$(dirname "$(realpath $0)")
cp $BDIR/install_tracker.exp $PKGDIR/
cd $PKGDIR

#https://physlets.org/tracker/installers/download.php?file=Tracker-6.2.0-linux-x64-installer.run
fname=Tracker-6.2.0-linux-x64-installer.run
wget -c https://physlets.org/tracker/installers/download.php?file=$fname -O $fname
chmod +x $fname
./install_tracker.exp
ln -sf /opt/tracker/tracker.sh /usr/local/bin/
