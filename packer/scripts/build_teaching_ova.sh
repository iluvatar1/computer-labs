#!/usr/bin/env bash
set -euo pipefail

MNAME=${MNAME:-base_slack_machine}
LOGNAME=${LOGNAME:-teaching}
PROVFILE=${PROVFILE:-provision_vars-teaching.json} # can use other provision files

BDIR=$(dirname $(realpath $0))

echo "Creating base machine in virtualbox" && \
FIRMWARE=bios MACHINENAME=$MNAME bash "${BDIR}/"create_base_machine.sh && \
echo "Installing slackware system and packages" && \
PACKER_LOG=1 packer build -var ISO_URL=$HOME/Downloads/iso/slackware64-current-install-dvd.iso -var MACHINENAME=${MNAME} -var CPUS=2 "${BDIR}/../"slackware64-current-A-install.json &> /tmp/log-A-$LOGNAME.txt && \
echo "Finishing slackware install and configuration" && \
PACKER_LOG=1 packer build -var MACHINENAME=${MNAME} "${BDIR}/../"slackware64-current-B-finish_install.json &> /tmp/log-B-$LOGNAME.txt && \
echo "Setting up machine with smaller lilo time etc" && \
PACKER_LOG=1 packer build -var MACHINENAME=${MNAME} "${BDIR}/../"slackware64-current-C-initial_setup.json &> /tmp/log-C-$LOGNAME.txt && \
echo "Installing packages " && \
PACKER_LOG=1 packer build -var MACHINENAME=${MNAME} "${BDIR}/../"slackware64-current-D-install_packages.json &> /tmp/log-D-$LOGNAME.txt && \
echo "Provisioning and exporting teaching machine" && \
PACKER_LOG=1 packer build -var-file ${PROVFILE} -var MACHINENAME=${MNAME} "${BDIR}/../"slackware64-current-E-provision.json &> /tmp/log-E-$LOGNAME.txt && \
echo "Finished."

#        [ "modifyvm", "{{.Name}}", "--firmware", "efi"],
#/usr/local/bin/VBoxManage modifyvm base_slack_machine --firmware bios #&& \
