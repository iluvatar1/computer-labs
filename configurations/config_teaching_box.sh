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
    cp "$BDIR/configurations/install_and_setup_doom_emacs.sh" /tmp/
    sudo -u live bash "/tmp/install_and_setup_doom_emacs.sh"
    config_shell_prompt
    #sudo -u live bash fix_tz_xfce4.sh
    install_spack
    # shared directory
    if [[ x"" ==  x"$(grep vboxsf /etc/rc.d/rc.local 2>/dev/null)" ]]; then
        echo "mount -t vboxsf -o rw,uid=1000,gid=1000 shared /media/hd" >> /etc/rc.d/rc.local
    fi
} &>> /var/log/log-teaching.txt
