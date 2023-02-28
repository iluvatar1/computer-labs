#!/bin/bash
#if [ -f /packages/spack/share/spack/setup-env.sh ]; then
#    source /packages/spack/share/spack/setup-env.sh
#fi

if [[ "root" == "$(whoami)" ]]; then
    return
fi

RED='\033[0;31m'
YELLOW='\033[0;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Sourcing spack ... (trying for 5 seconds) ${NC}"
timeout 5s stat /packages/spack/share/spack/setup-env.sh &>/dev/null
if [[ "$?" == "0" ]]; then
    source /packages/spack/share/spack/setup-env.sh
    echo -e "${GREEN}spack ready.${NC}"
else
    echo -e "${RED}ERROR:Problem sourcing spack from the packages server. ${NC}"
fi
