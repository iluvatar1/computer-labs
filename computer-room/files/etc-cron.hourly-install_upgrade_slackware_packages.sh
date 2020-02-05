#!/bin/env bash

SOURCE_DIR=/home/PACKAGES/
if [ -e $SOURCE_DIR ]; then
    echo "Installing pre-compiled packages ..."
    find $SOURCE_DIR -type f -iname "*t?z" -exec /sbin/upgradepkg --install-new {} \;
else
    echo "$SOURCE_DIR does not exists."
fi

SOURCE_FILE=/home/PACKAGES.list
if [ -f $SOURCE_FILE ]; then
    echo "Installing packages with slpkg (compiling from source, probably very slow) ..."
    source /root/.bashrc
    slpkg update
    slpkg upgrade
    rm /tmp/pkg-log 2>/dev/null 
    for pkgname in $(cat $SOURCE_FILE); do
	slpkg -s sbo $pkgname &>> /tmp/pkg-log
    done
else
    echo "$SOURCE_FILE does not exists."
fi

echo "Done."

