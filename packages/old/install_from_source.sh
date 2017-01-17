#!/bin/bash

# Check args
if [ "$#" -ne "1" ]; then
    printf "ERROR. USAGE:\n$0 source_to_install.[tar][.bz2][.gz]\n"
    exit 1
fi
if [ ! -e $1 ]; then 
    printf "ERROR. Source file $1 does not exists\n"
    exit 1
fi
printf "Installing $1\n"


# create temp dir and extract there
TEMPDIR=$(mktemp -d)
echo "TEMPDIR = $TEMPDIR"
cp $1 $TEMPDIR
cd $TEMPDIR
ls
pwd

# install process
NAME=$(basename $1)
echo "Uncompressing source $NAME"
tar xvf $NAME
BASE=${NAME%.tar*}
echo "Based name = $BASE"
cd $BASE
printf "Configuring ..\n."
./configure --prefix=/usr/local --libdir=/usr/local/lib
printf "make ...\n"
make
printf "make instal\nl"
make install

echo "DONE"