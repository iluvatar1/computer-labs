# TODO : put load in skeleton
if [ ! -f /usr/local/bin/starship ]; then
    cd /tmp
    wget https://starship.rs/install.sh
    sh install.sh -y
fi
#echo 'eval "$(/usr/local/bin/starship init bash)"' >> /root/.bashrc
#FNAME=/etc/profile.d/zzz-startship.sh
#if [ ! -f $FNAME ]; then
#    echo 'eval "$(/usr/local/bin/starship init bash)"' > $FNAME
#    chmod +x $FNAME
#fi
