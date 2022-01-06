#!/bin/env bash

###############################################################################
# Main 
###############################################################################
TYPE=${1}
if [[ x"CLIENT" != x"${TYPE}" ]] && [[ x"SERVER" != x"${TYPE}" ]]; then
    echo "ERROR. Usage : "
    echo "$0 TYPE"
    echo "where TYPE=CLIENT|SERVER"
    exit 1
fi

rm -f /tmp/log-${TYPE}.txt 2>/dev/null
{
    BDIR="$HOME/repos/computer-labs/"
    source $BDIR/configurations/config_functions.sh
    clone_or_update_config_repo
    # configure as TYPE
    cd "$BDIR/computer-room"
    # tangle the config file
    emacs --batch -l org config_computer_room.org -f org-babel-tangle
    # run the config script
    cd scripts
    ALL=1 bash bootstrap_slackware_computer_room.sh ../files $TYPE
} 2>&1 | tee /tmp/log-$TYPE.txt
