########################################
# General config
########################################
source package_helpers.sh
#SBO_CMD="sbopkg -e stop -B -k -i "
SBO_CMD="sboinstall -r -j 2 "

########################################
# SBO STUFF
########################################
echo "Installing sbopkg ..."
if ! hash sbopkg &>/dev/null ; then 
    wget -c https://github.com/sbopkg/sbopkg/releases/download/0.38.1/sbopkg-0.38.1-noarch-1_wsr.tgz
    /sbin/installpkg sbopkg-0.38.1-noarch-1_wsr.tgz
    /usr/sbin/sbopkg -r
else
    echo "    already installed"
fi

echo "Installing sbotools ..."
if ! hash sbosnap &>/dev/null ; then 
    wget -c https://pink-mist.github.io/sbotools/downloads/sbotools-2.2-noarch-1_SBo.tgz
    upgradepkg --install-new sbotools-2.2-noarch-1_SBo.tgz
    ln -sf /var/lib/sbopkg/SBo/14.2 /usr/sbo/repo 
    mkdir /etc/sbotools
    sboconfig -c FALSE
    #sbosnap fetch
else
    echo "    already installed"
fi

echo "Installing src2pkg ..."
if ! hash src2pkg &>/dev/null ; then 
    wget -c http://distro.ibiblio.org/amigolinux/download/src2pkg/src2pkg-3.0-noarch-2.txz
    upgradepkg --install-new src2pkg-3.0-noarch-2.txz
    src2pkg --setup
else
    echo "    already installed"
fi

BPACKAGES=(dropbox keepassx sshfs-fuse autossh xfce4-xkb-plugin flashplayer-plugin slim)
for bpkg in ${BPACKAGES[@]}; do
    $SBO_CMD $bpkg
done

# source packages
if [ ! hash kash 2> /dev/null  ]; then
    src2pkg http://gforge.inria.fr/frs/download.php/26773/kanif-1.2.2.tar.gz
    installpkg /tmp/kanif-1.2.2-x86_64-1.txz
fi
