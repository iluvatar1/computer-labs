#!/usr/bin/env bash
set -euo pipefail

MNAME=${MNAME:-base_slack_machine}
PROXY=${PROXY:-}

BDIR=$(dirname $(realpath $0))

echo "Creating base machine in virtualbox" && \
FIRMWARE=efi MACHINENAME=$MNAME bash "${BDIR}/"create_vbox_machine.sh && \
echo "Installing slackware system and packages" && \
PACKER_LOG=1 packer build -var ISO_URL=$HOME/Downloads/iso/slackware64-current-install-dvd.iso -var MACHINENAME=${MNAME} -var CPUS=2 "${BDIR}/../"slackware64-current-A-install.json &> /tmp/log-A.txt && \
echo "Finishing slackware install and configuration" && \
PACKER_LOG=1 packer build -var MACHINENAME=${MNAME} "${BDIR}/../"slackware64-current-B-finish_install.json &> /tmp/log-B.txt && \
echo "Setting up machine with smaller lilo time etc" && \
PACKER_LOG=1 packer build -var MACHINENAME=${MNAME} -var PROXY="$PROXY" "${BDIR}/../"slackware64-current-C-initial_setup.json &> /tmp/log-C.txt && \
echo "Finished."

#        [ "modifyvm", "{{.Name}}", "--firmware", "efi"],
#/usr/local/bin/VBoxManage modifyvm base_slack_machine --firmware bios #&& \
