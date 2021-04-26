#!/bin/env bash

###############################################################################
# Main 
###############################################################################
rm -f /var/log/log-install.txt 2>/dev/null
{
    BDIR="$HOME/repos/computer-labs/"
    source $BDIR/configurations/config_functions.sh
    clone_or_update_config_repo
    # configure as client
    cd "$BDIR/computer-room"
    # tangle the config file
    emacs --batch -l org config_computer_room.org -f org-babel-tangle
    # run the config script
    cd scripts
    echo 19 | bash bootstrap_slackware_computer_room.sh ../files CLIENT # 19 means all
} &>> /var/log/log-install.txt
