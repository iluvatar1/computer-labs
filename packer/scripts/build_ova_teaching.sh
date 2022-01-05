#!/usr/bin/env bash
set -euo pipefail

# example run:
# LOGBNAME=teaching PROVFILE=../config/provision_vars-teaching.json PROXY=http://192.168.10.1:3128 bash build_ova_teaching.sh

MNAME=${MNAME:-base_slack_machine}
LOGBNAME=${LOGBNAME:-teaching}
PROVFILE=${PROVFILE:-provision_vars-teaching.json} # can use other provision files
PROXY=${PROXY:-}

BDIR=$(dirname $(realpath $0))

echo "Installing packages " && \
PACKER_LOG=1 packer build -var MACHINENAME=${MNAME} -var PROXY="$PROXY" "${BDIR}/../"slackware64-current-D-install_packages.json &> /tmp/log-D-$LOGBNAME.txt && \
echo "Provisioning and exporting $LOGBNAME machine" && \
PACKER_LOG=1 packer build -var-file ${PROVFILE} -var MACHINENAME=${MNAME} "${BDIR}/../"slackware64-current-E-provision.json &> /tmp/log-E-$LOGBNAME.txt && \
echo "Finished."

#        [ "modifyvm", "{{.Name}}", "--firmware", "efi"],
#/usr/local/bin/VBoxManage modifyvm base_slack_machine --firmware bios #&& \
