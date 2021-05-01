#!/bin/env bash

###############################################################################
# Main 
###############################################################################
rm -f /var/log/log-teaching.txt 2>/dev/null
{
    BDIR="$HOME/repos/computer-labs/"
    source $BDIR/configurations/config_functions.sh
    # Configure teaching box
    check_live_user
    sudo -u live bash install_and_setup_doom_emacs.sh
    config_shell_prompt
    #sudo -u live bash fix_tz_xfce4.sh
    install_spack
} &>> /var/log/log-teaching.txt
