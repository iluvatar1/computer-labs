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

FNAME=Anaconda2-4.3.1-Linux-x86_64.sh
echo "Downloading anaconda."
wget -c  http://repo.continuum.io/archive/${FNAME}

echo "Installing Anaconda in batch mode ..."
rm -rf /opt/anaconda2 2> /dev/null
bash ${FNAME} -b -p /opt/anaconda2

# PUTTING ANCONDA ON THE PATH GENERATES PROBLEMS WITH COMPILATIONS. AVOID IT
if [ ! -f /etc/profile.d/anaconda.sh ]; then 
    echo 'export PATH="/usr/local/bin:$PATH"' > /etc/profile.d/anaconda.sh
    chmod +x /etc/profile.d/anaconda.sh
fi
source /etc/profile.d/anaconda.sh
# Better use soft links
for a in {de,}activate anaconda conda ipython{,2} jupyter{,-notebook} pip{,2} python{,2}  ; do
    ln -s /opt/anaconda2/bin/$a /usr/local/bin/
done

export PATH=/usr/local/bin/:$PATH

pip install --upgrade pip

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
pip install healpy


#echo "Installing visual python from apt, to be used with /usr/bin/python "
#echo vagrant | sudo apt-get install -y python-visual

echo "Done."
