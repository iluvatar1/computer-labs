#!/usr/bin/env bash
set -euo pipefail

echo "Creating base machine in virtualbox" && \
FIRMWARE=bios bash create_base_machine.sh && \
echo "Installing slackware system and packages" && \
PACKER_LOG=1 packer build -var ISO_URL=$HOME/Downloads/iso/slackware64-current-install-dvd.iso -var CPUS=2 slackware64-current-A-install.json &> log-A.txt && \
echo "Finishing slackware install and configuration" && \
PACKER_LOG=1 packer build slackware64-current-B-finish_install.json &> log-B.txt && \
echo "Setting up machine with smaller lilo time etc" && \
PACKER_LOG=1 packer build slackware64-current-C-initial_setup.json &> log-C.txt && \
echo "Installing packages " && \
PACKER_LOG=1 packer build slackware64-current-D-install_packages.json &> log-D.txt && \
echo "Provisioning and exporting teaching machine" && \
PACKER_LOG=1 packer build -var-file provision_vars-teaching.json slackware64-current-E-provision.json &> log-E.txt && \
echo "Finished."
#        [ "modifyvm", "{{.Name}}", "--firmware", "efi"],
#/usr/local/bin/VBoxManage modifyvm base_slack_machine --firmware bios #&& \
