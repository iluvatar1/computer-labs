#!/bin/bash
# TODO: Make idempotent
BNAME=opengrads-2.2.1.oga.1
FNAME=$BNAME-bundle-x86_64-pc-linux-gnu-glibc_2.17.tar.gz
cd /tmp
wget -c "https://ufpr.dl.sourceforge.net/project/opengrads/grads2/2.2.1.oga.1/Linux%20%2864%20Bits%29/$FNAME"
tar xvf $FNAME
cd $BNAME
mv Contents /opt/opengrads
echo "export PATH=/opt/opengrads:$PATH" >> /etc/profile.d/ZEXTRA-opengrads.sh
chmod +x /etc/profile.d/ZEXTRA-opengrads.sh
