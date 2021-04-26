#!/bin/env bash

###############################################################################
# Main 
###############################################################################
rm -f /var/log/log-packages.txt 2>/dev/null
{
    clone_config_repo
    BDIR="$HOME/repos/computer-labs/"
    source $BDIR/configurations/config_functions.sh
    cd "$BDIR/packages"
    COMPILE=NO bash install_packages_slackware.sh
} &>> /var/log/log-packages.txt
