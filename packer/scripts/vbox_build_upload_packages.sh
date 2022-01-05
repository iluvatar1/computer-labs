#!/usr/bin/env bash
set -euo pipefail

MNAME=${MNAME:-base_slack_machine} 
LOGBNAME=${LOGBNAME:-build}
BUILDFILE=${BUILDFILE:-NULL.json} # can use other provision files

BDIR=$(dirname $(realpath $0))

echo "Building and uploading packages " && \
PACKER_LOG=1 packer build -var MACHINENAME=${MNAME} -var CPUS=7 -var PROXY="http://192.168.10.1:3128/" -var TSNAPSHOT=${LOGBNAME} -var-file ${BUILDFILE} "${BDIR}/../"slackware64-current-D-build_packages.json &> /tmp/log-D-$LOGBNAME.txt && \
echo "Finished."

