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

echo "Do not forget to copy the local repo with your own packages, before creating the environment"

echo "Done"
