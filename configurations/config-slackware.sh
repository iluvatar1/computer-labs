########################################
# GENERAL SYSTEM SETTINGS
########################################
echo "Changing default init to 4 ..."
sed -i.bck 's/id:3:initdefault:/id:4:initdefault:/' /etc/inittab

echo "Chmod +x  network stuff ..."
chmod +x /etc/rc.d/rc.wireless
chmod +x /etc/rc.d/rc.networkmanager

########################################
# PACKAGES
########################################
echo "Installing sbopkg ..."
if ! hash sbopkg &>/dev/null ; then 
    wget -c https://github.com/sbopkg/sbopkg/releases/download/0.38.1/sbopkg-0.38.1-noarch-1_wsr.tgz
    /sbin/installpkg sbopkg-0.38.1-noarch-1_wsr.tgz
    /usr/sbin/sbopkg
else
    echo "    already installed"
fi


function install_pkg {
    echo "Installing package : ${1} ..."
    TDIR="tmp/downloads/${1}"
    mkdir -p ${TDIR} &&
	cd ${TDIR} &&
	wget -c "${3}" && 
	tar xf "${1}".tar.gz &&
	cd "${1}" && 
	wget -c "${4}" && 
	bash "${1}".SlackBuild &&
	/sbin/installpkg /tmp/"${1}"-"${5}"-x86_64-1_SBo.tgz &&
	cd ../../../ 
}

BNAME=dropbox
TESTNAME=dropboxd
BUILDNAME=https://slackbuilds.org/slackbuilds/14.2/network/dropbox.tar.gz
SRCNAME=https://d1ilhw0800yew8.cloudfront.net/client/dropbox-lnx.x86_64-15.4.22.tar.gz
VERSION=15.4.22
if ! hash "${TESTNAME}" &>/dev/null ; then
    install_pkg $BNAME $TESTNAME $BUILDNAME $SRCNAME $VERSION
fi

BNAME=keepassx
TESTNAME=keepassx
BUILDNAME=https://slackbuilds.org/slackbuilds/14.2/office/keepassx.tar.gz
SRCNAME=https://www.keepassx.org/releases/2.0.2/keepassx-2.0.2.tar.gz
VERSION=2.0.2
if ! hash "${TESTNAME}" &>/dev/null ; then
    install_pkg $BNAME $TESTNAME $BUILDNAME $SRCNAME $VERSION
fi


BNAME=sshfs-fuse
TESTNAME=sshfs
BUILDNAME=https://slackbuilds.org/slackbuilds/14.2/network/sshfs-fuse.tar.gz
SRCNAME=https://github.com/libfuse/sshfs/releases/download/sshfs_2.8/sshfs-2.8.tar.gz
VERSION=2.8
if ! hash "${TESTNAME}" &>/dev/null ; then
    install_pkg $BNAME $TESTNAME $BUILDNAME $SRCNAME $VERSION
fi

BNAME=autossh
TESTNAME=autossh
BUILDNAME=https://slackbuilds.org/slackbuilds/14.2/network/autossh.tar.gz
SRCNAME=http://www.harding.motd.ca/autossh/autossh-1.4c.tgz
VERSION=1.4c
if ! hash "${TESTNAME}" &>/dev/null ; then
    install_pkg $BNAME $TESTNAME $BUILDNAME $SRCNAME $VERSION
fi


BNAME=xfce4-xkb-plugin
TESTNAME=/usr/libexec/xfce4/panel-plugins/xfce4-xkb-plugin
BUILDNAME=https://slackbuilds.org/slackbuilds/14.2/desktop/xfce4-xkb-plugin.tar.gz
SRCNAME=http://archive.xfce.org/src/panel-plugins/xfce4-xkb-plugin/0.7/xfce4-xkb-plugin-0.7.1.tar.bz2
VERSION=0.7.1
if [ ! -f "${TESTNAME}" ]; then
    install_pkg $BNAME $TESTNAME $BUILDNAME $SRCNAME $VERSION
fi

BNAME=flashplayer-plugin
TESTNAME=/var/log/packages/flashplayer-plugin-24.0.0.194-x86_64-1_SBo
BUILDNAME=https://slackbuilds.org/slackbuilds/14.2/multimedia/flashplayer-plugin.tar.gz
SRCNAME=https://fpdownload.adobe.com/get/flashplayer/pdc/24.0.0.194/flash_player_npapi_linux.x86_64.tar.gz
VERSION=24.0.0.194
if [ ! -f "${TESTNAME}" ]; then
    install_pkg $BNAME $TESTNAME $BUILDNAME $SRCNAME $VERSION
fi





