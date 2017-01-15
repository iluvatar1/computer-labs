echo "EXECUTING : sandbox.sh"

if [ ! -d ~/bin ]; then
    mkdir -p ~/bin
fi

echo "Installing SandBox ..."
BDIR=/home/vagrant/PACKAGES/SANDBOX
if [ ! -d ${BDIR} ]; then
    mkdir -p ${BDIR}
fi
cd ${BDIR}
if [ ! -f ~/bin/SandBox ]; then
    if [ ! -d sandbox ]; then
	git clone https://bitbucket.org/iluvatar/sandbox
    fi
    cd sandbox
    git checkout .
    git pull
    make FC=gfortran
    ln -sf $PWD/BuildSample/build_SandBox ~/bin/
    ln -sf $PWD/POSTPRO/postpro_SandBox ~/bin/
    ln -sf $PWD/SANDBOX/SandBox ~/bin/
    cd ..
fi
if [ ! -f ~/bin/draw_SandBox_paraview.py ]; then
    cd sandbox
    chmod a+x $PWD/ADDON/draw_SandBox_paraview.py
    ln -sf $PWD/ADDON/draw_SandBox_paraview.py ~/bin/
    cd ..
fi

echo "Installing PyEVTK"
pip install PyEVTK

echo "Done."
