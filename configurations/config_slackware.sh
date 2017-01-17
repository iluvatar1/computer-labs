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


