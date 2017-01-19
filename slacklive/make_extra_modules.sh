echo "#####################################"
echo "CREATING anaconda MODULE ... "
if [ ! -d /tmp/modtemp/opt ]; then 
    mkdir -p /tmp/modtemp/opt
fi
echo "Copying anaconda2 to /tmp/modtemp/opt/ ..."
cp -auvf /opt/anaconda2 /tmp/modtemp/opt/
echo "Creating a local profile to modify the path for all users ... "
mkdir -p /tmp/modtemp/etc/profile.d
echo 'export PATH="/opt/anaconda2/bin:$PATH"' > /tmp/modtemp/etc/profile.d/anaconda.sh
chmod -x /tmp/modtemp/etc/profile.d/anaconda.sh
echo "Creating liveslack module ... "
bash liveslak/makemod.sh -i  /tmp/modtemp/ 0066-anaconda2-4.2.0-x86_64.sxz
echo "Done anaconda module."
echo "You can test the module contents with the command : "
echo "unsquashfs -l 0066-anaconda2-4.2.0-x86_64.sxz"
echo "#####################################"
echo 

echo "#####################################"
echo "CREATING valgrind MODULE"
mkdir -p /tmp/valgrind
cd /tmp/valgrind
wget -c https://slackbuilds.org/slackbuilds/14.2/development/valgrind.tar.gz
tar xf valgrind.tar.gz
cd valgrind
wget -c http://www.valgrind.org/downloads/valgrind-3.11.0.tar.bz2
bash valgrind.SlackBuild
cd
bash liveslak/makemod -i /tmp/valgrind-3.11.0-x86_64-1_SBo.tgz 0067-valgrind-3.11.0-x86_64-1_SBo.sxz
echo "Done valgrind module."
echo "You can test the module contents with the command : "
echo "unsquashfs -l 0067-valgrind-3.11.0-x86_64-1_SBo.sxz"
echo "#####################################"
echo 

echo "#####################################"
echo "CREATING config MODULE"
BDIR=$(mktemp /tmp/)
mkdir -p $BDIR/etc/profile.d/
echo "export LESS='-eRX' " >> $BDIR/etc/profile.d/less_custom_config.sh
chmod +x $BDIR/etc/profile.d/less_custom_config.sh
mkdir -p $BDIR/etc/rc.local
echo "ln -sf /etc/X11/xinit/xinitrc{.xfce,}" >> $BDIR/etc/rc.local
echo "loadkeys la-latin1" >> $BDIR/etc/rc.local
bash liveslak/makemod.sh -i  $BDIR/   0068-customconfig-0.0.1-x86_64.sxz
echo "Done config module."
echo "You can test the module contents with the command : "
echo "unsquashfs -l 0068-customconfig-0.0.1-x86_64.sxz"
echo "#####################################"
echo 


