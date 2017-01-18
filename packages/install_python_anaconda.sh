echo "Installing anaconda ..."

if  hash conda 2> /dev/null ; then
    echo "    -> already installed"
    exit 0
fi

cd /tmp
if [ ! -d ANACONDA ] ; then
    mkdir ANACONDA &>/dev/null
fi
cd ANACONDA

FNAME=Anaconda3-4.2.0-Linux-x86_64.sh
if [ ! -f ${FNAME} ]; then
    echo "Downloading anaconda."
    wget -c  http://repo.continuum.io/archive/${FNAME}
fi

echo "Installing Anaconda ..."
bash ${FNAME} -b

if [ ! -f /etc/profile.d/anaconda.sh ]; then 
    echo 'export PATH="/opt/anaconda2/bin:$PATH"' > /etc/profile.d/anaconda.sh
    chmod +x /etc/profile.d/anaconda.sh
fi

source /etc/profile.d/anaconda.sh

echo "Updating conda"
conda update -y conda
echo "Installing vpython"
conda install -y -c vpython vpython
echo "Installing other packages"
conda install -y matplotlib scipy numpy sympy seaborn  
echo "Updating ipython"
conda install -y ipython
echo "Updating pyEVTK"
pip install pyEVTK
echo "Installing  healpy"
conda install healpy


#echo "Installing visual python from apt, to be used with /usr/bin/python "
#echo vagrant | sudo apt-get install -y python-visual

echo "Done."
