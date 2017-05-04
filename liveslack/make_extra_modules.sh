echo "This script is meant to be run on a Slackware 14.2 installation where the liveslack repo is updated and inside ~/Downloads"


MAKEMOD=makemod
LIVESLACKBDIR=/root/Downloads/liveslak/
MODDIR=/root/Downloads/mods_liveslack

echo "Updating liveslack repo ..."
cd $LIVESLACKBDIR
git pull
cd

cd $MODDIR
if [ ! -f 0066-anaconda2-4.3.1-x86_64.sxz ]; then 
    echo "#####################################"
    echo "CREATING anaconda MODULE ... "
    if [ ! -d /tmp/modtemp/opt ]; then 
	mkdir -p /tmp/modtemp/opt
    fi
    echo "Copying anaconda2 to /tmp/modtemp/opt/ ..."
    cp -auvf /opt/anaconda2 /tmp/modtemp/opt/
    echo "Creating a local profile to modify the path for all users ... "
    mkdir -p /tmp/modtemp/etc/profile.d
    echo 'export PATH=/usr/local/bin/:$PATH"' > /tmp/modtemp/etc/profile.d/anaconda.sh
    echo 'for a in {de,}activate anaconda conda ipython{,2} jupyter{,-notebook} pip{,2} python{,2}  ; do ln -sf /opt/anaconda2/bin/$a /usr/local/bin/ &> /dev/null; done ' > /tmp/modtemp/etc/profile.d/anaconda.sh
    chmod +x /tmp/modtemp/etc/profile.d/anaconda.sh

    echo "Creating liveslack module ... "
    bash $LIVESLACKBDIR/$MAKEMOD -i  /tmp/modtemp/ 0066-anaconda2-4.3.1-x86_64.sxz
    rm -rf /tmp/modtemp
    echo "Done anaconda module."
    echo "You can test the module contents with the command : "
    echo "unsquashfs -l 0066-anaconda2-4.3.1-x86_64.sxz"
    echo "#####################################"
    echo
fi

BNAME=valgrind-3.12.0-x86_64-1_SBo
cd $MODDIR
if [ ! -f 0067-${BNAME}.sxz ]; then
    echo "#####################################"
    echo "CREATING valgrind MODULE"
    if [ ! -f /tmp/$BNAME.tgz ]; then 
	mkdir -p /tmp/valgrind &&
	    cd /tmp/valgrind &&
	    wget -c https://slackbuilds.org/slackbuilds/14.2/development/valgrind.tar.gz &&
	    tar xf valgrind.tar.gz &&
	    cd valgrind &&
	    wget -c http://www.valgrind.org/downloads/valgrind-3.12.0.tar.bz2 &&
	    bash valgrind.SlackBuild
    fi
    cd $MODDIR
    bash $LIVESLACKBDIR/$MAKEMOD -i /tmp/${BNAME}.tgz 0067-${BNAME}.sxz 
    rm -rf /tmp/valgrind
    echo "Done valgrind module."
    echo "You can test the module contents with the command : "
    echo "unsquashfs -l 0067-${BNAME}.sxz"
    echo "#####################################"
    echo 
fi

# BNAME=customconfig-0.0.1-x86_64
# cd $MODDIR
# if [ ! -f 0068-${BNAME}.sxz ]; then
#     echo "#####################################"
#     echo "CREATING config MODULE"
#     BDIR=$(mktemp -d -p /tmp/)
#     mkdir -p $BDIR/etc/profile.d/
#     echo "export LESS='-eRX' " >> $BDIR/etc/profile.d/custom_config.sh
#     chmod +x $BDIR/etc/profile.d/less_custom_config.sh
#     #mkdir -p $BDIR/etc/rc.local
#     echo "# ln -sf /etc/X11/xinit/xinitrc{.xfce,}" >> $BDIR/etc/profile.d/custom_config.sh
#     echo "# loadkeys la-latin1" >> $BDIR/etc/profile.d/custom_config.sh
#     chmod +x $BDIR/etc/profile.d/custom_config.sh
#     bash $LIVESLACKBDIR/$MAKEMOD -i  $BDIR/   0068-customconfig-0.0.1-x86_64.sxz
#     rm -rf $BDIR
#     echo "Done config module."
#     echo "You can test the module contents with the command : "
#     echo "unsquashfs -l 0068-customconfig-0.0.1-x86_64.sxz"
#     echo "#####################################"
#     echo 
# fi
    
