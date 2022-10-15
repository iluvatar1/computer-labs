if [[ "efi" != "$1" ]] && [[ "bios" != "$1" ]]; then
    echo "Error. You must specify the firmware:"
    echo "$0 bios|efi"
    exit 1
fi
FIRMWARE=$1


#PACKER_LOG=1 packer build -var FIRMWARE=${FIRMWARE} -var-file config/cfg-D-build_pkgs.json slackware64-current-D-build_packages.json | tee /tmp/log-D-build_${FIRMWARE}.txt && \
    PACKER_LOG=1 packer build -var FIRMWARE=${FIRMWARE} -var-file config/cfg-D-install_pkgs.json slackware64-current-D-install_packages.json | tee  /tmp/log-D-install_${FIRMWARE}.txt && \
    PACKER_LOG=1 packer build -var FIRMWARE=${FIRMWARE} -var-file config/cfg-E-provision-computer-room.json slackware64-current-E-provision.json | tee /tmp/log-E-provision_${FIRMWARE}.txt && \
    PACKER_LOG=1 packer build -var FIRMWARE=${FIRMWARE} -var-file config/cfg-clonezilla-vbox-to-img.json clonezilla-vbox-to-img.json | tee /tmp/log-clonezilla.txt && \
    echo "Done"
    
