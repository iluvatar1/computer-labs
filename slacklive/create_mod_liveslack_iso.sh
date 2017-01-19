echo "Creating liveslack iso with custom modules"
mount -o loop /dev/sr0 /mnt/dvd
mkdir -p /tmp/slackwarelive_staging
rsync -av -P /mnt/dvd/ /tmp/slackwarelive_staging/
umount /mnt/dvd
cp -avu Downloads/006*sxz /tmp/slackwarelive_staging/liveslak/addons/
cd /tmp/slackwarelive_staging/
bash ~/Downloads/liveslak/make_slackware_live.sh -G
echo "Done. Copy the iso where you need it."
