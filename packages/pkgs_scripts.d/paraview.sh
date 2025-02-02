#!/bin/bash
SCRIPT_DIR=$(dirname "$(realpath $0)")

cd /mnt/scratch
DIRNAME=ParaView-5.13.2-MPI-Linux-Python3.10-x86_64
FILENAME=$DIRNAME.tar.gz
echo $DIRNAME
echo $FILENAME
wget -c "https://www.paraview.org/paraview-downloads/download.php?submit=Download&version=v5.13&type=binary&os=Linux&downloadFile=ParaView-5.13.2-MPI-Linux-Pyt\
hon3.10-x86_64.tar.gz" -O $FILENAME
if [ ! -d "$DIRNAME" ]; then
    tar xf $FILENAME
fi
ln -s $DIRNAME paraview

