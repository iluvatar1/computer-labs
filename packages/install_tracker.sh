cd /packages/SLACKWARE
fname=Tracker-6.0.10-linux-64bit-installer.run
wget https://physlets.org/tracker/installers/download.php?file=$fname -O $fname
./install_tracker.exp
ln -s /opt/tracker/tracker.sh /usr/local/bin/
