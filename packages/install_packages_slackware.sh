# list of packages to install (common mainly by name)
if [ "$1" != "BASIC" ] && [ "$1" != "UTIL" ] && [ "$1" != "EXTRA" ] ; then
    echo "Error. Call this script as :"
    echo "$0 [BASIC|UTIL|EXTRA]"
    exit 1
fi

SBO_CMD="sboinstall -r -j 2"

PKG=
SRC=
if [ "$1" == "BASIC" ]; then
    PKG="monit fail2ban grace corkscrew djview4 ffmpeg graphviz inkscape lame  smplayer unrar valgrind valkyrie  chromium libreoffice openmpi octave dropbox vlc scribus audacity armadillo pip parallel pdftk"
fi
for pkgname in $PKG; do
    $SBO_CMD $pkgname
done
		   
NUMERIC="eigen3 fltk netcdf arpack atlas gsl hdf5 lapack suitsparse QtiPlot scidavis"

UTIL="kile kdenlive filezilla povray texmaker libticonv gocr msmtp lyx geany wine eagle skype twolame mplayer-codecs32 flashplayer-plugin pyserial dfc  wol sshfs-fuse acpica virtualbox-kernel virtualbox-kernel-addons virtualbox-extension-pack paraview  PyYAML  cppcheck iotop ntpclient  proxychains proxytunnel "
EXTRA="GoogleEarth blender"
