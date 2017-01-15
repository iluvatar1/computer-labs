echo "EXECUTING : lmgc90.sh"

echo "Building LMGC90 ..."
BDIR=~/PACKAGES/LMGC90
if [ ! -d ${BDIR} ]; then
    mkdir -p ${BDIR}
fi
cd ${BDIR}

#wget -c http://www.vtk.org/files/release/6.3/vtkpython-6.3.0-Linux-64bit.tar.gz 

echo vagrant | sudo apt-get install -y gmsh python-vtk6 gmsh libgmsh-dev 
conda install -y vtk
pip install -y pygmsh 

if [ ! -d lmgc90_user ]; then
    export GIT_SSL_NO_VERIFY=True
    git clone https://git-xen.lmgc.univ-montp2.fr/lmgc90/lmgc90_user.git
fi
cd lmgc90_user
git pull origin master
cd ..
if [ ! -d build ]; then
    mkdir build 
    cd build
    cmake ../lmgc90_user/src
    make
    if [ "0" -ne "$?" ]; then
	cd ..;
	rm -rf build
    fi
fi

echo "Adding lmgc90 stuff to bashrc ..."
STATUS=$(grep lmgc90_user ~/.bashrc | grep -v grep)
if [ "" == "$STATUS" ]; then
    if [ -z ${PYTHONPATH} ]; then
	echo export PYTHONPATH=${BDIR}/build >> ~/.bashrc
    else
	echo export PYTHONPATH=${PYTHONPATH}:${BDIR}/build >> ~/.bashrc
    fi
fi
echo "Done."
