#!/usr/bin/env bash
set -euo pipefail

# Example run:
# TYPE=CLIENT PROVFILE=../config/provision_vars-computer_room.json bash build_ova_computer_room.sh bios|efi
# NOTE: Packages assumed to be already installed 
# TYPE can be CLIENT SERVER or TEACHING

if [[ "efi" != "$1" ]] && [[ "bios" != "$1" ]]; then
    echo "Error. You must specify the firmware:"
    echo "$0 bios|efi"
    exit 1
fi
FIRMWARE=$1
PROVFILE=${PROVFILE:-config/cfg-E-provision-computer_room.json-EXAMPLE} # can use other provision files
#PROVFILE=${PROVFILE:-config/cfg-E-teachingVM.json-EXAMPLE} # can use other provision files
if [[ ! -f $PROVFILE ]]; then
    echo "Error. File not found -> $PROVFILE"
    exit 1
fi
BDIR=$(dirname $(realpath $0))

echo "Provisioning and exporting if needed " && \
PACKER_LOG=1 packer build -var-file ${PROVFILE} "${BDIR}/../"slackware64-current-E-provision.json &> /tmp/log-E.txt && \
echo "Finished."

