echo "Building and installing mercurydpm ..."
BDIR=~/PACKAGES/MERCURYDPM
if [ ! -d ${BDIR} ]; then
    mkdir -p ${BDIR}
fi

cd ${BDIR}
mkdir MercuryDPM &>/dev/null
cd MercuryDPM
if [ ! -d MercurySource ]; then 
    svn checkout https://svn.MercuryDPM.org/SourceCode/Beta MercurySource
    mkdir MercuryBuild 2> /dev/null
    cd MercuryBuild
    cmake ../MercurySource
    make fullTest
fi

echo "Done."
