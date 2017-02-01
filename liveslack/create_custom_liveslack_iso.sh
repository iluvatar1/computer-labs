echo "Creating liveslack iso with custom modules"

STAGING_DIR=/tmp/slackwarelive_staging

mount -o loop /dev/sr0 /mnt/dvd && 
mkdir -p ${STAGING_DIR} && 
rsync -av -P --delete /mnt/dvd/ ${STAGING_DIR}/ && 
umount /mnt/dvd && 
cp -avu ~/Downloads/006*sxz ${STAGING_DIR}/liveslak/addons/ &&
cd ${STAGING_DIR}/ &&
OUTPUT=/opt/ bash ~/Downloads/liveslak/make_slackware_live.sh -G && 
echo "Done. Copy the iso where you need it."
