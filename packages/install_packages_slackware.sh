# list of packages to install (common mainly by name)
if [ "$1" != "BASIC" ] && [ "$1" != "MISC" ] && [ "$1" != "NUMERIC" ] && [ "$1" != "EXTRA" ] && [ "$1" != "SALAFIS" ]; then
    echo "Error. Call this script as :"
    echo "$0 [BASIC|NUMERIC|MISC|EXTRA|SALAFIS]"
    exit 1
fi

# fix PATH to remove anaconda stuff
PATH=/usr/local/sbin:/usr/sbin:/sbin:/usr/local/bin:/usr/bin:/bin:/usr/games:/usr/lib64/kde4/libexec:/usr/lib64/qt/bin:/usr/share/texmf/bin

# use slpkg
source /root/.bashrc
slpkg upgrade
SLPKG_CMD="slpkg -s sbo"

# Setup packages
PKG=
SRC=
if [ "$1" == "BASIC" ]; then
    PKG="monit fail2ban corkscrew pip parallel ganglia ganglia-web wol ssh-fuse valgrind openmpi modules cppcheck iotop"
elif [ "$1" == "NUMERIC" ]; then
    PKG="fltk netcdf arpack blas atlas hdf5 lapack suitsparse armadillo octave R rstudio-desktop"    
elif [ "$1" == "MISC" ]; then
    PKG="valkyrie paraview grace djview4 lame kile kdenlive dropbox pdftk  filezilla scribus povray ninja chromium smplayer vlc inkscape ffmpeg audacity graphviz libticonv gocr msmtp lyx  wine eagle skype twolame mplayer-codecs32 flashplayer-plugin pyserial dfc acpica virtualbox-kernel virtualbox-kernel-addons virtualbox-extension-pack  PyYAML ntpclient  proxychains proxytunnel libreoffice"
elif [ "$1" == "EXTRA" ]; then
    PKG="GoogleEarth blender QtiPlot scidavis"
elif [ "$1" == "SALAFIS" ]; then
    PKG="arduino geany kdiff3"
fi

for pkgname in $PKG; do
    $SLPKG_CMD $pkgname
    if [ "$?" != "0" ]; then
	echo "# Error installing package -> $pkgname"
    fi
done
		   

