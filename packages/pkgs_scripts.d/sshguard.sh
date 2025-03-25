#!/bin/bash
# TODO: Make idempotent
# NOTE: In recent sbopkg and slpkg, it installs the latest version

BNAME=sshguard
VERSION=2.4.2
TARGZNAME=${BNAME}-${VERSION}.tar.gz
DNAME=$(mktemp -d)
echo $DNAME
cd $DNAME
wget -c "https://slackbuilds.org/slackbuilds/15.0/network/${BNAME}.tar.gz"
tar xvf ${BNAME}.tar.gz
cd $BNAME
wget -c "https://sinalbr.dl.sourceforge.net/project/${BNAME}/${BNAME}/${VERSION}/${TARGZNAME}"
VERSION=$VERSION bash $BNAME.SlackBuild
upgradepkg --install-new /tmp/${BNAME}*tgz
chmod +x /etc/rc.d/rc.${BNAME}
