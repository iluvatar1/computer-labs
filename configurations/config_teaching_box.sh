#!/bin/env bash

###############################################################################
# Functions definitions
###############################################################################
source config_functions.sh


###############################################################################
# Main 
###############################################################################
rm -f /var/log/log-install.txt 2>/dev/null
{
    # Configure teaching box
    check_live_user
    sudo -u live bash install_and_setup_doom_emacs.sh
    config_shell_prompt
    #sudo -u live bash fix_tz_xfce4.sh
    install_spack
} &>> /var/log/log-install.txt
