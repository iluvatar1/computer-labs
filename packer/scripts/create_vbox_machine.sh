#!/usr/bin/env bash
set -euo pipefail

# Based on: https://www.andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/

FIRMWARE=${FIRMWARE:-VALUE}
MACHINENAME=${MACHINENAME:-base_slack_machine_${FIRMWARE}}
BASEFOLDER=${BASEFOLDER:-"$HOME/VirtualBox VMs/"}
DISKPATH="${BASEFOLDER}/${MACHINENAME}/${MACHINENAME}_DISK.vdi"

# Download debian.iso
#if [ ! -f ./debian.iso ]; then
#    wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.9.0-amd64-netinst.iso -O debian.iso
#fi

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype "Linux26_64" --register --basefolder "$BASEFOLDER"
#Set memory and network
VBoxManage modifyvm $MACHINENAME --ioapic on
VBoxManage modifyvm $MACHINENAME --memory 2048 --vram 128
VBoxManage modifyvm $MACHINENAME --nic1 nat
VBoxManage modifyvm $MACHINENAME --nic2 nat
#Create Disk and connect Iso
VBoxManage createhd --filename "$DISKPATH" --size 120000 --format VDI
VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci --portcount 3 --bootable on
VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$DISKPATH"
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
#VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/debian.iso
#VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage modifyvm $MACHINENAME --firmware $FIRMWARE

#Enable RDP
#VBoxManage modifyvm $MACHINENAME --vrde on
#VBoxManage modifyvm $MACHINENAME --vrdemulticon on --vrdeport 10001

#Start the VM
#VBoxHeadless --startvm $MACHINENAME
