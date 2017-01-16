#!/bin/bash

function start_info {
    echo "This script installs automatically several basic packages, assuming network and repositories are correctly setted up. "
}

function end_info {
    echo "##################################################"
    echo "Done."
}

function usage {
    echo "Usage:"
    echo "$1 LINUX_FLAVOR"
    echo "LINUX_FLAVOR : UBUNTU or SLACKWARE"
}

if [[ $# != 1 ]]; then 
    start_info
    usage $0
    exit 1
fi

LINUX=$1
if [[ $LINUX != "UBUNTU" && $LINUX != "SLACKWARE" ]]; then
    echo "Bad linux=$LINUX given"
    usage
    exit 1
fi

if [[ $LINUX == "UBUNTU" ]] ; then 
    echo "DO NOT FORGET TO INSTALL FROM SOURCE : dfc gnu-parallel src2pkg voro++  eigen dssp"
elif [[ $LINUX == "SLACKWARE" ]] ; then 
    echo "DO NOT FORGET TO INSTALL FROM SOURCE : kanif fftw pymol jabref triangle  tetgen kcachegrind vim-gtk gromacs cython xpaint src2pkg voro++ dssp armadillo"
fi

# list of packages to install (common mainly by name)
BASIC_COMMON="monit fail2ban kile texmaker python-simpy ipython grace povray  blender corkscrew djview4 ffmpeg gocr graphviz inkscape lame lyx msmtp smplayer unrar valgrind geany wine libreoffice eagle skype octave dropbox vlc scribus filezilla kdenlive audacity"
# UBUNTU
BASIC_UBUNTU="openssh-client openssh-server  nfs-common nfs-kernel-server openvpn kanif portmap nis quota quotatool git gitk nmap wget build-essential paraview sshfs libfftw3-3 libfftw3-dev libfftw3-doc freeglut3 freeglut3-dev libfltk1.1 libfltk1.1-dev tcl-dev tk-dev texlive-full emacs tmux vim vim-gtk python-numpy  python-scipy pymol python-matplotlib gnuplot gv netcdf-bin libnetcdf-dev jabref libtriangle-1.6 ddd libtriangle-dev chromium-browser libarmadillo-dev libarmadillo2 libarpack++2-dev libarpack++2c2a libatlas-base-dev libatlas-dev libboost-dev  libgsl0-dev libgsl0ldbl libhdf5-openmpi-dev libhdf5-openmpi-1.8.4 h5utils hdf5-tools htop libmp3lame0 lame liblapack-dev mplayer mplayer2 openmpi-bin openmpi-common libsuitesparse-dev tetgen libtet1.4.2 libtet1.4.2-dev  kcachegrind  flashplugin-installer python-pip unity-2d mesa-utils csh cython wxglade pil wxpython gimp mercurial cmake xfig imagemagick python-serial eagle-data libcmpicppimpl0 libcmpicppimpl0-dev picprog wakeonlan"
#GROMACS_UBUNTU="gromacs gromacs-dev "
BASIC_UBUNTU="$BASIC_UBUNTU $GROMACS_UBUNTU"
# SLACKWARE
BASIC_SLACKWARE="eigen3 libticonv fltk numpy scipy matplotlib netcdf chromium arpack atlas gsl openmpi hdf5 twolame lapack mplayer-codecs32 smplayer  suitesparse flashplayer-plugin pip pyserial dfc parallel wol sshfs-fuse acpica virtualbox-kernel virtualbox-kernel-addons virtualbox-extension-pack valkyrie netcdf paraview  PyYAML QtiPlot chromium cppcheck iotop ntpclient numpy org-mode pdftk proxychains proxytunnel texlive "
EXTRA_SLACKWARE="GoogleEarth Blender"

#  Full package list
PACKAGES="$BASIC_COMMON"
if [[ $LINUX == "UBUNTU" ]] ; then 
    PACKAGES="$PACKAGES $BASIC_UBUNTU"
elif [[ $LINUX == "SLACKWARE" ]] ; then 
    PACKAGES="$PACKAGES $BASIC_SLACKWARE"
fi

# create sbopkg queues file
# Check if sqg is installed
sqg -v
if [[ $? != 0 ]]; then 
    echo "Please copy the sqg binary from /usr/share/doc/sbopkg-VERSION/contrib to the path"
    echo "Do not forget to create /root/queues temp directory and configure it inside the sqg scrip."
    echo "Also, inside the script, uncomment the SKIP_EMPTY option to set it to no"
    exit 1
fi

# Create queues 
QDIR=/var/lib/sbopkg/queues/
LIVEDVD_QFILE=livedvd-pakages.sqf
    
#Use additional queues and set all prerequisites lists
if [[ $LINUX == "SLACKWARE" ]] ; then 
    #sbopkg -r
    #mkdir /root/queues
    #sqg -a
    # get all queue files
    rm -rf $QDIR; mkdir $QDIR
    cd $QDIR
    git clone https://git.gitorious.org/sbopkg-slackware-queues/sbopkg-slackware-queues.git ./
    # licedvd queue file
    rm -f $LIVEDVD_QFILE
    for a in $PACKAGES; do
	echo "@$a.sqf" >> $LIVEDVD_QFILE  # use sqf files
	#echo "$a.sqf" >> $LIVEDVD_QFILE  # use sqf files
    done
    cd # return to /root
    #mv /root/queues/*sqf $QDIR
fi



# add repo for macbook wireless
#if [[ $LINUX == "UBUNTU" ]] ; then 
#add-apt-repository ppa:mpodroid/mactel
#fi


# update the packages list
if [[ $LINUX == "UBUNTU" ]] ; then 
    apt-get update 1> report-out.txt 2> report-err.txt
elif [[ $LINUX == "SLACKWARE" ]] ; then 
    echo 
    #slackpkg update 
    #sbopkg -r  # NEW
fi


# install packages 
if [[ $LINUX == "UBUNTU" ]] ; then 
    for pack in $PACKAGES; do 
	echo "Installing package :      $pack"
	echo "Installing package :      $pack" >> report-out.txt
	echo "Installing package :      $pack" >> report-err.txt
	apt-get -y --force-yes install $pack 1>> report-out.txt 2>> report-err.txt
	echo "Status = $?"
    done
elif [[ $LINUX == "SLACKWARE" ]] ; then 
    echo "Installing packages at queue : $LIVEDVD_QFILE"
    #sbopkg -k -i $LIVEDVD_QFILE 1>> report-out.txt 2>> report-err.txt
    sbopkg -k -i $LIVEDVD_QFILE 
fi
echo "##################################################"
echo "Done."
