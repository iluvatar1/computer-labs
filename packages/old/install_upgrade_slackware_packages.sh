#!/bin/env bash
echo "This script install patches and packages using slpkg."
#slackpkg -batch=on -default_answer=y update gpg
#slackpkg -batch=on -default_answer=y update
#slackpkg -batch=on -default_answer=y upgrade patches
#slackpkg -batch=on -default_answer=y install-new # must be before upgrade-all
#slackpkg -batch=on -default_answer=y upgrade-all
#echo "Updating slpkg ..."
#slpkg upgrade

echo "Source bashrc for proxy information ..."
source /root/.bashrc

echo "Configuring and updating slpkg ... "
# Check slackware version
if [ x"$(grep 14.2+ /etc/slackware-version | grep -v grep)" == x"" ]; then
    sed -i.bck 's/RELEASE=.*/RELEASE=stable/' /etc/slpkg/slpkg.conf;
else
    sed -i.bck 's/RELEASE=.*/RELEASE=current/' /etc/slpkg/slpkg.conf;
fi
slpkg update
slpkg upgrade

echo "Installing official patches ... "
slpkg -s slack "" --patches

SOURCE_DIR=/home/PACKAGES/
echo "Installing precompiled packages inside directory ${SOURCE_DIR} ..."
if [ -e $SOURCE_DIR ]; then
    echo "Installing pre-compiled packages ..."
    find $SOURCE_DIR -type f -iname "*t?z" -exec /sbin/upgradepkg --install-new {} \;
else
    echo "$SOURCE_DIR does not exists."
fi

SOURCE_FILE=/home/PACKAGES.list
echo "Installing packages listed on file  ${SOURCE_FILE} (compiling from source, probably very slow ) ..."
if [ -f $SOURCE_FILE ]; then
    rm -f /tmp/pkg-log 2>/dev/null 
    for pkgname in $(cat $SOURCE_FILE); do
	echo "Installing : $pkgname"
	slpkg -s sbo $pkgname &>> /tmp/pkg-log
    done
else
    echo "$SOURCE_FILE does not exists."
fi
