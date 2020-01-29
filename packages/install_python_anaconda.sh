echo "Installing miniconda3 ..."

if [ -f /etc/profile.d/conda.sh ]; then 
    source /etc/profile.d/conda.sh
    conda activate
fi

if  hash conda 2> /dev/null ; then
    echo "    -> already installed"
    #exit 0
else 
    cd /tmp
    if [ ! -d ANACONDA ] ; then
	      mkdir ANACONDA &>/dev/null
    fi
    cd ANACONDA

    FNAME=Miniconda3-latest-Linux-x86_64.sh
    echo "Downloading miniconda3 ..."
    wget -c  https://repo.continuum.io/miniconda/${FNAME} || exit 1
    
    echo "Installing miniconda3 in batch mode ..."
    rm -rf /opt/miniconda3 2> /dev/null
    bash ${FNAME} -b -p /opt/miniconda3 || exit 1

    #export PATH=/opt/anaconda3/bin/:/usr/local/bin/:$PATH
    source /opt/miniconda3/etc/profile.d/conda.sh || exit 1
    if ! hash conda 2> /dev/null ; then
	echo "Cannot find conda"
	echo "PATH: $PATH"
	exit 1
    fi
    
    pip install --upgrade pip
    
    echo "Updating conda"
    conda update -y conda
    echo "Installing vpython"
    conda install -y -c vpython vpython
    echo "Installing other packages"
    conda install -y matplotlib scipy numpy sympy seaborn  
    echo "Installing ipython and jupyter"
    conda install -y ipython jupyter
    echo "Updating pyEVTK"
    pip install pyEVTK
    echo "Installing  healpy"
    pip install healpy

fi

if [ ! -f /etc/profile.d/conda.sh ]; then 
    cp {/opt/miniconda3,}/etc/profile.d/conda.sh 
    chmod +x /etc/profile.d/conda.sh
fi

## PUTTING ANCONDA ON THE PATH GENERATES PROBLEMS WITH COMPILATIONS. AVOID IT.
## JUST LINK THE NEEDED BINARIES (SEE BELOW)
#if [ ! -f /etc/profile.d/anaconda.sh ]; then 
#    echo 'export PATH="/usr/local/bin:$PATH"' > /etc/profile.d/anaconda.sh
#    chmod +x /etc/profile.d/anaconda.sh
#fi
#source /etc/profile.d/anaconda.sh
## Better use soft links
#for a in {de,}activate anaconda conda ipython{,3} jupyter{,-notebook} pip{,3} python{,3}  ; do
#    ln -sf /opt/anaconda3/bin/$a /usr/local/bin/
#done

echo "Done."
