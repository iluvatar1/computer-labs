echo "EXECUTING: anaconda.sh"

cd /home/vagrant/PACKAGES
if [ ! -d ANACONDA ] ; then
    mkdir ANACONDA &>/dev/null
fi
cd ANACONDA

FNAME=Anaconda3-4.1.1-Linux-x86_64.sh

echo "Installing and configuring  Anaconda ..."
if [ ! -f ${FNAME} ]; then
    echo "Downloading anaconda."
    wget -c  http://repo.continuum.io/archive/${FNAME}
fi

if [ ! -f /home/vagrant/anaconda3/bin/conda ]; then
    echo "Installing Anaconda ..."
    bash ${FNAME} -b
fi

touch /home/vagrant/.bashrc
if grep -q anaconda3 /home/vagrant/.bashrc &> /dev/null  ; then
    echo "Anaconda PATH already configured "
    . ~/.bashrc
else 
    export PATH="/home/vagrant/anaconda3/bin:$PATH"
    echo 'export PATH="/home/vagrant/anaconda3/bin:$PATH"' >> /home/vagrant/.bashrc
fi

echo "Updating conda"
conda update -y conda
echo "Installing vpython"
conda install -y -c vpython vpython
echo "Installing other packages"
conda install -y matplotlib scipy numpy sympy seaborn  
echo "Updating ipython"
conda install -y ipython

pip install pyEVTK

echo "Installing visual python from apt, to be used with /usr/bin/python "
echo vagrant | sudo apt-get install -y python-visual

echo "Done."
