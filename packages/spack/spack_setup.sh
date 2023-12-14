#!/bin/bash

BDIR=/packages/
cd $BDIR

if [[ ! -d spack ]]; then 
    echo "Clonning spack repo, checking out latest"
    git clone https://github.com/spack/spack.git
else
    echo "spack dir already present. "
fi

cd spack

echo "Checking out latest and setting up env"
git fetch origin releases/latest:latest
git checkout latest
source spack/share/spack/setup-env.sh # setup Spack

echo "Do not forget to copy the local repo with your own packages, before creating the environment"

echo "Done"
