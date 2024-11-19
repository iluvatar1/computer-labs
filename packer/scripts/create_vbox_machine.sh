#!/usr/bin/env bash
set -euo pipefail

# Based on: https://www.andreafortuna.org/2019/10/24/how-to-create-a-virtualbox-vm-from-command-line/

function usage(){
    echo "FIRMWARE=bios|efi HARDDISK_TYPE=sda|nvme0n1 $0"
    exit 1
}

if [[ "$FIRMWARE" != "bios" ]] && [[ "$FIRMWARE" != "efi" ]]; then
    usage
fi

if [[ "$HARDDISK_NAME" != "sda" ]] && [[ "$HARDDISK_NAME" != "nvme0n1" ]]; then
    usage
fi

SUFFIX="_${FIRMWARE}_${HARDDISK_NAME}"

MACHINENAME=${MACHINENAME:-base_slack_machine${SUFFIX}}
BASEFOLDER=${BASEFOLDER:-"/opt/VirtualBox VMs/"}
DISKPATH="${BASEFOLDER}/${MACHINENAME}/${MACHINENAME}_DISK.vdi"

MEMORY=${MEMORY:-3000} # GB
HARDDISK_SIZE=${HARDDISK_SIZE:-220000} # MB



# Download debian.iso
#if [ ! -f ./debian.iso ]; then
#    wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-9.9.0-amd64-netinst.iso -O debian.iso
#fi

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype "Linux26_64" --register --basefolder "$BASEFOLDER"
#Set memory and network
VBoxManage modifyvm $MACHINENAME --ioapic on
VBoxManage modifyvm $MACHINENAME --memory $MEMORY --vram 256
VBoxManage modifyvm $MACHINENAME --nic1 nat
VBoxManage modifyvm $MACHINENAME --nic2 nat
#Create Disk and connect Iso
VBoxManage createhd --filename "$DISKPATH" --size $HARDDISK_SIZE --format VDI
if [[ "$HARDDISK_NAME" == "sda" ]]; then 
    VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci --portcount 3 --bootable on
    VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  "$DISKPATH"
fi
if [[ "$HARDDISK_NAME" == "nvme0n1" ]]; then 
    VBoxManage storagectl $MACHINENAME --name "NVMe Controller" --add pcie --controller NVMe --portcount 1 --bootable on
    VBoxManage storageattach $MACHINENAME --storagectl "NVMe Controller" --port 0 --device 0 --type hdd --medium  "$DISKPATH"
fi

VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
#VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/debian.iso
#VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none
VBoxManage modifyvm $MACHINENAME --firmware $FIRMWARE

#Enable RDP
#VBoxManage modifyvm $MACHINENAME --vrde on
#VBoxManage modifyvm $MACHINENAME --vrdemulticon on --vrdeport 10001

#Start the VM
#VBoxHeadless --startvm $MACHINENAME
