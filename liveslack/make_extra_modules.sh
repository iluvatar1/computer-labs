echo "This script is meant to be run on a Slackware 14.2 installation where the liveslack repo is updated and inside ~/Downloads"


MAKEMOD=makemod
LIVESLACKBDIR=/root/Downloads/liveslak/
MODDIR=/root/Downloads/mods_liveslack
mkdir -p $MODDIR

echo "Updating liveslack repo ..."
cd $LIVESLACKBDIR
git pull
cd


function create_miniconda {
    cd $MODDIR
    BNAME=Miniconda2-latest-Linux-x86_64
    if [ ! -f 0066-$BNAME.sxz ]; then 
        echo "#####################################"
        echo "CREATING miniconda MODULE ... "

        if [ ! -d /opt/miniconda2 ]; then
	          echo "Installing miniconda and packages ...."
	          if [ ! -f ~/Downloads/$BNAME.sh ]; then 
	              echo "Downloading ..."
	              wget https://repo.continuum.io/miniconda/$BNAME.sh -O ~/Downloads/$BNAME.sh
	          fi
	          echo "Installing (onto /opt/miniconda2, batch mode)..."
	          bash ~/Downloads/$BNAME.sh -b -p /opt/miniconda2
	          echo "Done installing miniconda"
        fi
        
        echo "Installing/upgrading some packages ..."
        echo "Updating conda"
        /opt/miniconda2/bin/conda update -y conda
        echo "Installing vpython"
        /opt/miniconda2/bin/conda install -y -c vpython vpython
        echo "Installing other packages"
        /opt/miniconda2/bin/conda install -y matplotlib scipy numpy sympy seaborn  
        echo "Updating ipython"
        /opt/miniconda2/bin/conda install -y ipython

        cd $MODDIR
        echo "Creating temp dir (if it does not exist) ..." 
        if [ ! -d /tmp/modtemp/opt ]; then 
	          mkdir -p /tmp/modtemp/opt
        fi
        echo "Copying miniconda2 to /tmp/modtemp/opt/ ..."
        cp -auvf /opt/miniconda2 /tmp/modtemp/opt/
        echo "Creating a local profile to modify the path for all users ... "
        mkdir -p /tmp/modtemp/etc/profile.d
        echo 'export PATH=/usr/local/bin/:$PATH"' > /tmp/modtemp/etc/profile.d/anaconda.sh
        echo 'for a in {de,}activate anaconda conda ipython{,2} jupyter{,-notebook} pip{,2} python{,2}  ; do ln -sf /opt/miniconda2/bin/$a /usr/local/bin/ &> /dev/null; done ' > /tmp/modtemp/etc/profile.d/anaconda.sh
        chmod +x /tmp/modtemp/etc/profile.d/anaconda.sh

        echo "Creating miniconda liveslack module ... "
        bash $LIVESLACKBDIR/$MAKEMOD -i  /tmp/modtemp/ 0066-$BNAME.sxz
        rm -rf /tmp/modtemp
        echo "Done miniconda module."
        echo "You can test the module contents with the command : "
        echo "unsquashfs -l 0066-$BNAME.sxz"
        echo "#####################################"
        echo
    fi
}

function create_valgrind {
    BNAME=valgrind-3.13.0-x86_64-1_SBo
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
	              wget -c ftp://sourceware.org/pub/valgrind/valgrind-3.13.0.tar.bz2 &&
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
}

function create_generic {
    NAME=$1
    BNAME=$2
    SLACKBUILD_URL="$3"
    SOURCE_URL="$4"
    PKGNUM=$5
    cd $MODDIR
    if [ ! -f ${PKGNUM}-${BNAME}.sxz ]; then
        echo "#####################################"
        echo "CREATING ${NAME} MODULE"
        if [ ! -f /tmp/$BNAME.tgz ]; then 
	          mkdir -p /tmp/${NAME} &&
	              cd /tmp/${NAME} &&
	              wget -c ${SLACKBUILD_URL} &&
	              tar xvf ${NAME}.tar.gz &&
	              cd ${NAME} &&
	              wget -c ${SOURCE_URL} && 
	              bash ${NAME}.SlackBuild
        fi
        cd $MODDIR
        bash $LIVESLACKBDIR/$MAKEMOD -i /tmp/${BNAME}.tgz ${PKGNUM}-${BNAME}.sxz &&
        rm -rf /tmp/${NAME} &&
        echo "Done ${NAME} module." &&
        echo "You can test the module contents with the command : " &&
        echo "unsquashfs -l ${PKGNUM}-${BNAME}.sxz" &&
        echo "#####################################" &&
        echo 
    fi
}

function create_paraview {
    create_generic qt5 qt5-5.7.1-x86_64-1_SBo "https://slackbuilds.org/slackbuilds/14.2/libraries/qt5.tar.gz" "download.qt.io/official_releases/qt/5.7/5.7.1/single/qt-everywhere-opensource-src-5.7.1.tar.xz" 0068
    create_generic paraview paraview-5.4.1-x86_64-1_SBo  "https://slackbuilds.org/slackbuilds/14.2/graphics/paraview.tar.gz" "https://www.paraview.org/files/v5.4/ParaView-v5.4.1.tar.gz" 0069
}

echo "Please select package to create :"
printf "0) ALL \n1) Miniconda \n2) valgrind \n3) paraview\n"
read option
case $option in
    0) create_miniconda
       create_valgrind
       create_paraview
       ;;
    1) create_miniconda
       ;;
    2) create_valgrind
       ;;
    3) create_paraview
       ;;
    *) echo "Bad option. Exiting"
       exit 1
       ;;
esac


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
    
