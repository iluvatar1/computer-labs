echo "EXECUTING:  dem.sh"

BDIR=/home/vagrant/PACKAGES/DEM
if [ ! -d ~/bin ]; then
    mkdir -p ~/bin
fi

if [ ! -d ${BDIR} ]; then
    mkdir -p ${BDIR}
fi

cd ${BDIR}
if [ ! -f ~/bin/dem.x ]; then
    if [ ! -d dem ]; then
	git clone https://bitbucket.org/iluvatar/dem
    else
	cd dem
	git remote update
	if [ "" == "$(git status  | grep up-to-date)" ]; then 
	    echo "Need to update repo"
	    git pull
	    rm -f ~/bin/dem.x
	fi
	cd ..
    fi
    cd dem
    echo vagrant | sudo bash addons/install_dependencies.sh
    make -j 2 OPT=1 WITH_NETCDF=1 WITH_VTK=1 
    for prog in dem.x postpro_main.x prepro_initializer.x postpro_display_paraview.x; do
	ln -sf $PWD/bin/${prog} ~/bin/${prog}
    done
    for prog in $PWD/addons/*; do
	ln -sf $prog ~/bin/
    done
fi

echo "Done."
