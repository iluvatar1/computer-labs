# ligggths
echo "EXECUTING : liggghts.sh"

BDIR=~/PACKAGES/LIGGGHTS
if [ ! -d ${BDIR} ]; then
    mkdir -p ${BDIR}
fi
cd ${BDIR}
# following http://www.cfdem.com/installation-tutorial , http://www.cfdem.com/system/files/githubaccess_public_1.pdf
REPO=LIGGGHTS-PUBLIC
BINL=/usr/bin/liggghts
if [ ! -e ${BINL} ]; then
    echo "Building Liggghts ..."
    if [ ! -d ${REPO} ]; then
	git clone https://github.com/CFDEMproject/${REPO}.git
    fi
    cd ${REPO}
    git checkout .
    git pull
    # compilation
    cd src
    #make clean-all
    make -j 2 openmpi
    echo vagrant | sudo ln -sf ${PWD}/lmp_openmpi ${BINL}
fi

# postprocessing, following http://www.cfdem.com/node/23
echo "Installing lpp and pizza for liggghts post-processing"
echo vagrant | sudo apt-get install -y python-tk python-imaging-tk python-pil python-pexpect  python-pmw python-opengl libtogl1
if [ ! -d ~/bin ]; then
    mkdir -p ~/bin
fi
cd ${BDIR}
if [ ! -f ~/bin/lpp ]; then
    if [ ! -d LPP ]; then
	#git clone git@github.com:CFDEMproject/LPP.git
	git clone https://github.com/CFDEMproject/LPP.git
    fi
    cd LPP
    ./install.sh # not necessary  since LPP_DIR will have the full path
fi
#STATUS=$(grep LPP_DIR ~/.bashrc | grep -v grep)
#if [ "" == "$STATUS" ]; then
#    echo "" >> ~/.bashrc
#    echo "# lpp : liggghts postprocessing" >> ~/.bashrc
#    echo export LPP_DIR=${BDIR}/LPP/src >> ~/.bashrc
#    export LPP_DIR=${BDIR}/LPP/src 
#    echo export LPP_NPROCS=2  >> ~/.bashrc
#    export LPP_NPROCS=2 
#    echo export LPP_CHUNKSIZE=1  >> ~/.bashrc
#    export LPP_CHUNKSIZE=1
#    echo alias lpp="'python -i $LPP_DIR/lpp.py --cpunum $LPP_NPROCS --chunksize $LPP_CHUNKSIZE'"  >> ~/.bashrc
#fi
echo "Done."
