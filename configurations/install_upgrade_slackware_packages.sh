#!/bin/env bash
echo "This script install patches and packages using slpkg."

echo "Source bashrc for proxy information ..."
source /root/.bashrc

echo "Configuring and updating slpkg ... "
# Check slackware version
if [ x"$(grep 14.2+ /etc/slackware-version | grep -v grep)" != x"" ]; then
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

echo "Installing latest firefox (beta channel) ..."
tname=$HOME/Downloads/latest_firefox.sh
if [ ! -f $tname ]; then
    wget https://gist.githubusercontent.com/ruario/9672798/raw/8838b901c411289c7780d68eadeb8f655c9d46c2/latest-firefox.sh -O $tname
fi
FFCHANNEL=beta bash $tname --install &>/tmp/ff-log

echo "Done."

