echo "Executing openlb.sh"

BDIR=~/PACKAGES/OPENLB
if [ ! -d ${BDIR} ]; then
    mkdir ${BDIR}
fi

cd ${BDIR}

PNAME=olb-1.0r0.tgz
BNAME=${PNAME%.tgz}
if [ ! -f $PNAME ]; then
    wget -c http://www.optilb.com/openlb/wp-content/uploads/2016/03/$PNAME
fi
if [ ! -d $BNAME ]; then
    tar xf $PNAME
fi

cd $BNAME
echo "Compiling openlb lib ..."
make -j 2
echo "Compiling samples"
make -j 2 samples

echo "Done."
