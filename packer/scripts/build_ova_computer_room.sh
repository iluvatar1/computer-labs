#!/usr/bin/env bash
set -euo pipefail

# Example run:
# TYPE=CLIENT PROVFILE=../config/provision_vars-computer_room.json bash build_ova_computer_room.sh
# NOTE: Packages assumed to be already installed after creation ofteaching box

PROVFILE=${PROVFILE:-provision_vars-computer_room.json} # can use other provision files
if [[ ! -f $PROVFILE ]]; then
    echo "Error. File not found -> $PROVFILE"
    exit 1
fi
BDIR=$(dirname $(realpath $0))

echo "Provisioning and exporting machine" && \
PACKER_LOG=1 packer build -var-file ${PROVFILE} "${BDIR}/../"slackware64-current-E-provision.json &> /tmp/log-E.txt && \
echo "Finished."

