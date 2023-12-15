#!/bin/bash

BDIR=/packages/
cd $BDIR

if [[ ! -d spack ]]; then 
    echo "Clonning spack repo, checking out latest"
    git clone --branch=releases/v0.21 https://github.com/spack/spack.git || exit 1
else
    echo "spack dir already present. "
fi

cd spack

echo "Checking out latest and setting up env"
#git fetch origin releases/latest:latest
#git checkout latest
#git fetch origin releases/v0.21.0
#git checkout v0.21.0
source $BDIR/spack/share/spack/setup-env.sh # setup Spack

echo "Adding new versions (check if needed)"
echo "pigz 2.8 (fixes the wrong libz version detection)"
spack checksum -a pigz 2.8
echo "Soci 4.0.3 (fixes errors altstackmem integral constant)"
spack checksum -a soci 4.0.3

echo "Do not forget to copy the local repo with your own packages, before creating the environment"

echo "Done"
