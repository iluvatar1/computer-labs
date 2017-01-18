########################################
# GENERAL SYSTEM SETTINGS
########################################
echo "Changing default init to 4 ..."
sed -i.bck 's/id:3:initdefault:/id:4:initdefault:/' /etc/inittab

echo "Chmod +x  network stuff ..."
chmod +x /etc/rc.d/rc.wireless
chmod +x /etc/rc.d/rc.networkmanager

echo "Chmod +x  nfsd stuff ..."
chmod +x /etc/rc.d/rc.nfsd

echo "Configuring slim login manager"
if [ x"" == x"$(grep slim /etc/rc.d/rc.4)" ]; then
    sed -i.bck '/echo "Starting up X11 session manager..."/a \\n# start SLiM ...\nif [ -x /usr/bin/slim ]; then exec /usr/bin/slim; fi ' /etc/rc.d/rc.4
    ln -sf /etc/X11/xinit/xinitrc.xfce /etc/X11/xinitrc
fi

echo "Done."
