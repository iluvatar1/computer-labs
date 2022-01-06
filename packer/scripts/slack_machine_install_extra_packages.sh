#!/usr/bin/env bash
set -euo pipefail

# example run:
# MNAME=base_slack_machine PROXY=http://192.168.10.1:3128 bash slack_machine_install_extra_packages.sh

MNAME=${MNAME:-base_slack_machine}
PROXY=${PROXY:-}
BDIR=$(dirname $(realpath $0))

echo "Installing packages on $MNAME" && \
PACKER_LOG=1 packer build -var MACHINENAME=${MNAME} -var PROXY="$PROXY" "${BDIR}/../"slackware64-current-D-install_packages.json &> /tmp/log-D.txt && \
echo "Finished."

