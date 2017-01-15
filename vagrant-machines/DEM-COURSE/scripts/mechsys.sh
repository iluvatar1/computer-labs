echo "EXECUTING : mechsys.sh"

MECHSYS_ROOT=~/PACKAGES/MECHSYS
export MECHSYS_ROOT

# Install needed packages
#bash ${MECHSYS_ROOT}/mechsys/scripts/install_apt_deps.bash : this script is interactive and does not work with vagrant provision
# Needed packages installed in the packages script

#if [ -h $MECHSYS_ROOT/mechsys/mechsys ]; then
#echo "Mechsys already installed. "
#echo "FILE : $MECHSYS/mechsys/mechsys exists."
#exit 0
#fi

if [ "" == "$(grep MECHSYS_ROOT ~/.bashrc | grep -v grep)" ]; then
    echo export MECHSYS_ROOT=~/PACKAGES/MECHSYS >> ~/.bashrc
fi

mkdir -p ${MECHSYS_ROOT}
cd ${MECHSYS_ROOT}
if [ ! -d mechsys ]; then 
    hg clone http://hg.savannah.nongnu.org/hgweb/mechsys
else
    cd mechsys;
    hg pull
fi

echo "Compiling additional packages for mechsys ..."
bash ${MECHSYS_ROOT}/mechsys/scripts/install_compile_deps.bash

if [ ! -d msys_tutorial ]; then
    echo "Installing and compiling tutorials ..."
    wget -c -nc http://mechsys.nongnu.org/downloads/msys_tutorial.tar.gz >/dev/null
    tar xf msys_tutorial.tar.gz
    cd msys_tutorial
    cmake ./
    make -j 2 &> /dev/null
fi

if [ ! $(command -v visit) ]; then
    echo "Configuring visit"
    if [ ! -f visit2_10_2.linux-x86_64-ubuntu14.tar.gz ]; then 
	wget -c http://portal.nersc.gov/project/visit/releases/2.10.2/visit2_10_2.linux-x86_64-ubuntu14.tar.gz
    fi
    if [ ! -d visit2_10_2.linux-x86_64 ]; then 
	tar xf visit2_10_2.linux-x86_64-ubuntu14.tar.gz
    fi
    if [ "" == "$(grep visit2 ~/.bashrc | grep -v grep)" ]; then
	echo export PATH=$PATH:~/PACKAGES/MECHSYS/visit2_10_2.linux-x86_64/bin >> ~/.bashrc
    fi
fi    

echo "Done."
