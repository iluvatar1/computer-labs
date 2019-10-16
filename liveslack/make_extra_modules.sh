echo "This script is meant to be run on a Slackware 14.2 installation where the liveslack repo is updated and inside ~/Downloads"

MAKEMOD=makemod
LIVESLACKBDIR=${HOME}/Downloads/liveslak/
MODDIR=${HOME}/Downloads/mods_liveslack
mkdir -p $LIVESLACKBDIR
mkdir -p $MODDIR

echo "Updating liveslack repo ..."
cd $LIVESLACKBDIR
if [ ! -d .git ]; then 
    git clone http://bear.alienbase.nl/cgit/liveslak .
fi
git pull
cd

function check_status {
    if [[ x"0" !=  x"$?" ]]; then
	echo "Error in previous command. Exiting."
	exit 1
    fi
}

function create_miniconda {
    cd $MODDIR
    #BNAME=Miniconda3-4.7.10-Linux-x86_64 
    BNAME=Miniconda3-4.6.14-Linux-x86_64 
    TDIR=/tmp/miniconda3/
    if [ ! -s 0065-$BNAME.sxz ]; then 
        echo "#####################################"
        echo "CREATING miniconda MODULE ... "
	
        if [ ! -d $TDIR/opt ]; then
	          echo "Installing miniconda and packages onto $TDIR ...."
		  #mkdir -p $TDIR/opt
		  MD5SUM="1c945f2b3335c7b2b15130b1b2dc5cf4"
	          if [[ x"$MD%SUM" != x"$(md5sum ~/Downloads/$BNAME.sh | awk '{print $1}')" ]]; then 
	              echo "Downloading ..."
	              wget https://repo.continuum.io/miniconda/$BNAME.sh -O ~/Downloads/$BNAME.sh
		      check_status
	          fi
	          echo "Installing (onto $TDIR, batch mode)..."
	          echo bash ~/Downloads/$BNAME.sh -b -p $TDIR/opt
	          bash ~/Downloads/$BNAME.sh -b -p $TDIR/opt
		  check_status
	          echo "Done installing miniconda"
	else
	    echo "Directory already exists: $TDIR "
        fi
        
        echo "Installing/upgrading some packages ..."
        echo "Updating conda"
        $TDIR/opt/bin/conda update -y conda
        echo "Installing vpython"
        $TDIR/opt/bin/conda install -y -c vpython vpython
        echo "Installing other packages"
        $TDIR/opt/bin/conda install -y matplotlib scipy numpy sympy seaborn  
        echo "Updating ipython"
        $TDIR/opt/bin/conda install -y ipython

        cd $MODDIR
        echo "Creating a local profile to modify the path for all users ... "
        mkdir -p $TDIR/etc/profile.d
        echo 'export PATH=/usr/local/bin/:$PATH"' > $TDIR/etc/profile.d/anaconda.sh
        echo 'for a in {de,}activate anaconda conda ipython{,3} jupyter{,-notebook,-lab} pip{,3} python{,3}  ; do ln -sf /opt/miniconda3/bin/$a /usr/local/bin/ &> /dev/null; done ' > $TDIR/etc/profile.d/anaconda.sh
        chmod +x $TDIR/etc/profile.d/anaconda.sh

        echo "Creating miniconda liveslack module ... "
        bash $LIVESLACKBDIR/$MAKEMOD -i  $TDIR 0065-$BNAME.sxz
        #rm -rf $TDIR
        echo "Done miniconda module."
        echo "You can test the module contents with the command : "
        echo "unsquashfs -l 0065-$BNAME.sxz"
        echo "#####################################"
        echo
    else
	echo "Package already exists: $MODDIR/0065-$BNAME.sxz"
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
        if [ ! -s /tmp/$BNAME.tgz ]; then 
	          mkdir -p /tmp/${NAME} &&
	              cd /tmp/${NAME} &&
	              wget -c ${SLACKBUILD_URL} &&
	              tar xvf ${NAME}.tar.gz &&
	              cd ${NAME} &&
	              wget -c ${SOURCE_URL} && 
	              sudo bash ${NAME}.SlackBuild
        fi
	if [ -s "${PKGNUM}-${BNAME}.sxz" ]; then
            cd $MODDIR
            bash $LIVESLACKBDIR/$MAKEMOD -i /tmp/${BNAME}.tgz ${PKGNUM}-${BNAME}.sxz &&
		rm -rf /tmp/${NAME} &&
		echo "Done ${NAME} module." &&
		echo "You can test the module contents with the command : " &&
		echo "unsquashfs -l ${PKGNUM}-${BNAME}.sxz" &&
		echo "#####################################" &&
		echo
	fi
    fi
}

function create_valgrind {
    create_generic valgrind valgrind-3.15.0-x86_64-1_SBo "https://slackbuilds.org/slackbuilds/14.2/development/valgrind.tar.gz" "ftp://sourceware.org/pub/valgrind/valgrind-3.15.0.tar.bz2" 0067
}

function create_openmpi {
    create_generic openmpi openmpi-4.0.1-x86_64-1_SBo "https://slackbuilds.org/slackbuilds/14.2/system/openmpi.tar.gz" "https://download.open-mpi.org/release/open-mpi/v4.0/openmpi-4.0.1.tar.bz2" 0068
}

function create_obs {
    create_generic ffmepg ffmpeg-3.2.4-x86_64_SBo "https://slackbuilds.org/slackbuilds/14.2/multimedia/ffmpeg.tar.gz" "http://www.ffmpeg.org/releases/ffmpeg-3.2.4.tar.xz" 0069
    create_generic x264 x264-20170225-x86_64-1_SBo "https://slackbuilds.org/slackbuilds/14.2/multimedia/x264.tar.gz" "http://ftp.videolan.org/x264/snapshots/x264-snapshot-20170225-2245-stable.tar.bz2" 0070
    create_generic obs-studio obs-studio-23.2.1-x86_64_SBo "https://slackbuilds.org/slackbuilds/14.2/multimedia/obs-studio.tar.gz" "https://github.com/obsproject/obs-studio/archive/23.2.1/obs-studio-23.2.1.tar.gz" 0071
}

function create_openscad {
    create_generic openscad openscad-2015.03.3-x86_64_SBo "https://slackbuilds.org/slackbuilds/14.2/graphics/openscad.tar.gz" "http://files.openscad.org/openscad-2015.03-3.src.tar.gz" 0072
}

function create_paraview {
    NAME=paraview
    PKGNUM=0066
    BNAME=paraview-5.4.1-x86_64-oquendo
    #PKG_NAME="ParaView-5.4.1-Qt5-OpenGL2-MPI-Linux-64bit.tar.gz"
    PKG_NAME="ParaView-5.6.1-osmesa-MPI-Linux-64bit.tar.gz"
    PKG_BNAME="${PKG_NAME%.tar.gz}"
    #PKG_URL="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.4&type=binary&os=Linux&downloadFile=${PKG_NAME}"
    PKG_URL="https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.6&type=binary&os=Linux&downloadFile=${PKG_NAME}"
    # using the binaries from Paraview
    cd $MODDIR
    if [ ! -f ${PKGNUM}-${BNAME}.sxz ]; then
        echo "#####################################"
        if [ ! -f /tmp/${BNAME}.txz ]; then 
            echo "CREATING ${NAME} PACKAGE"
	    mkdir -p /tmp/${NAME} &&
	        cd /tmp/${NAME} &&
	        wget -c -nc -O "${PKG_NAME}" "${PKG_URL}"  &&
	        tar xvf ${PKG_NAME} &&
		mkdir -p build/opt &&
		mv ${PKG_BNAME} build/opt/  &&
		cd build &&
		mkdir -p usr/local/bin &&
		echo "/opt/${PKG_BNAME}/bin/paraview" > usr/local/bin/paraview &&
		chmod +x usr/local/bin/paraview &&
		echo "/opt/${PKG_BNAME}/bin/pvpython" > usr/local/bin/pvpython &&
		chmod +x usr/local/bin/pvpython &&
		makepkg -l y -c n /tmp/${BNAME}.txz &&
		echo "DONE: CREATING ${NAME} PACKAGE"
        fi
	cd $MODDIR
        echo "CREATING ${NAME} SQUASHFS MODULE"
	bash $LIVESLACKBDIR/$MAKEMOD -i /tmp/${BNAME}.txz ${PKGNUM}-${BNAME}.sxz &&
            echo "Done ${NAME} module." &&
            echo "You can test the module contents with the command : " &&
            echo "unsquashfs -l ${PKGNUM}-${BNAME}.sxz" &&
            echo "#####################################" &&
            echo 
    fi    
    # From source: 2017-12-07 - Does not work, paraview gives an error
    #create_generic qt5 qt5-5.7.1-x86_64-1_SBo "https://slackbuilds.org/slackbuilds/14.2/libraries/qt5.tar.gz" "download.qt.io/official_releases/qt/5.7/5.7.1/single/qt-everywhere-opensource-src-5.7.1.tar.xz" 0068
    #create_generic paraview paraview-5.4.1-x86_64-1_SBo  "https://slackbuilds.org/slackbuilds/14.2/graphics/paraview.tar.gz" "https://www.paraview.org/files/v5.4/ParaView-v5.4.1.tar.gz" 0069
}

echo "Please select package to create :"
printf "0) ALL \n 1) Miniconda \n 2) valgrind \n 3) paraview \n 4) openmpi \n 5) obs-studio \n 6) openscad \n"
read option
case $option in
    0) create_miniconda &
       #create_valgrind
       #create_paraview
       #create_openmpi
       create_obs &
       create_openscad ^
       ;;
    1) create_miniconda
       ;;
    2) create_valgrind
       ;;
    3) create_paraview
       ;;
    4) create_openmpi
       ;;
    5) create_obs
       ;;
    6) create_openscad
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
    
