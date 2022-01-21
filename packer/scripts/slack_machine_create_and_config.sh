#!/usr/bin/env bash
set -euo pipefail

if [[ "efi" != "$1" ]] && [[ "bios" != "$1" ]]; then
    echo "Error. You must specify the firmware:"
    echo "$0 bios|efi"
    exit 1
fi
FIRMWARE=$1
BNAME=${BNAME:-base_slack_machine}
MACHINENAME=${BNAME}_${FIRMWARE}
PROXY=${PROXY:-}

echo "MACHINENAME: ${MACHINENAME}"
sleep 4

BDIR=$(dirname $(realpath $0))

echo "Creating base machine in virtualbox" && \
FIRMWARE=$FIRMWARE MACHINENAME=$MACHINENAME bash "${BDIR}/"create_vbox_machine.sh && \
echo "Installing slackware system and packages" && \
PACKER_LOG=1 packer build -var FIRMWARE=${FIRMWARE} -var-file config/cfg-A-install.json "${BDIR}/../"slackware64-current-A-install.json &> /tmp/log-A.txt && \
echo "Finishing slackware install and configuration" && \
PACKER_LOG=1 packer build -var FIRMWARE=${FIRMWARE} -var-file config/cfg-B-finish_install.json "${BDIR}/../"slackware64-current-B-finish_install.json &> /tmp/log-B.txt && \
echo "Setting up machine with smaller lilo time etc" && \
PACKER_LOG=1 packer build -var FIRMWARE=${FIRMWARE} -var-file config/cfg-C-initial_setup.json "${BDIR}/../"slackware64-current-C-initial_setup.json &> /tmp/log-C.txt && \
echo "Finished."

#        [ "modifyvm", "{{.Name}}", "--firmware", "efi"],
#/usr/local/bin/VBoxManage modifyvm base_slack_machine --firmware bios #&& \
