# list of packages to install (common mainly by name)
if [ "$1" != "BASIC" ] && [ "$1" != "MISC" ] && [ "$1" != "NUMERIC" ] && [ "$1" != "EXTRA" ] && [ "$1" != "SALAFIS" ]; then
    echo "Error. Call this script as :"
    echo "$0 [BASIC|NUMERIC|MISC|EXTRA|SALAFIS]"
    exit 1
fi

SBO_CMD="sboinstall -r -j 2"

PKG=
SRC=
if [ "$1" == "BASIC" ]; then
    PKG="monit fail2ban grace corkscrew djview4 lame  unrar smplayer valgrind valkyrie libreoffice openmpi blas openblas octave dropbox pip parallel pdftk"
elif [ "$1" == "NUMERIC" ]; then
    PKG="eigen3 fltk netcdf arpack atlas gsl hdf5 lapack suitsparse armadillo openblas"    
elif [ "$1" == "MISC" ]; then
    PKG="kile kdenlive filezilla scribus povray texmaker chromium smplayer vlc inkscape ffmpeg audacity graphviz libticonv gocr msmtp lyx geany wine eagle skype twolame mplayer-codecs32 flashplayer-plugin pyserial dfc  wol sshfs-fuse acpica virtualbox-kernel virtualbox-kernel-addons virtualbox-extension-pack paraview  PyYAML  cppcheck iotop ntpclient  proxychains proxytunnel "
elif [ "$1" == "EXTRA" ]; then
    PKG="GoogleEarth blender QtiPlot scidavis"
elif [ "$1" == "SALAFIS" ]; then
    PKG="octave arduino"
fi

for pkgname in $PKG; do
    $SBO_CMD $pkgname
done
		   

