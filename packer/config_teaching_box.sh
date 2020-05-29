#!/bin/sh

set -x
set -e

# Install the virtualbox additions
mount -o loop VBoxGuestAdditions.iso /mnt/
cd /mnt
./VBoxLinuxAdditions.run || echo "Some error on VBox Linux Add install, but we will continue ..."
cd /
umount /mnt

# Config the machine
mkdir /root/repos 2> /dev/null
cd /root/repos || exit
git clone https://github.com/iluvatar1/computer-labs
cd computer-labs/configurations
bash config_teaching_box.sh
