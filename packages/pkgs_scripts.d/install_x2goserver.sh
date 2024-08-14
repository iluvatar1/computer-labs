#!/bin/bash
printf "Q\nP\n" | MAKEFLAGS=-j$(nproc) sbopkg -i x2goserver

# check if binary is working
x2godbadmin --createdb &>/dev/null
if [[ "$?" == "0" ]]; then
    echo "x2go seems to be working. Exiting"
    exit 0
fi

# remove old packages
removepkg /var/log/packages/perl-DBD-SQLite-*
removepkg /var/log/packages/nxlibs-*
removepkg /var/log/packages/x2goserver-*

# update sbo
sbopkg -r

# create queue
sqg -p x2goserver

# build and install package
printf "Q\nP\n" | MAKEFLAGS=-j$(nproc) sbopkg -i x2goserver

# test
x2godbadmin --createdb &>/dev/null
echo "Status after running x2godbadmin: $?"



