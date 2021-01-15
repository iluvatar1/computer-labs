#!/bin/env bash

###############################################################################
# Functions definitions
###############################################################################
setup () {
    echo "Setting up environment"
    echo "Cloning computer-labs repo ..."
    if [ ! -d "$HOME/repos" ]; then
        mkdir -p "$HOME/repos"
    fi
        cd "$HOME/repos/" || exit
    if [ ! -d "computer-labs" ]; then
        git clone https://github.com/iluvatar1/computer-labs
    fi
    cd computer-labs || exit
    git pull
}

check_live_user () {
    MSG="Checking if live user exists, otherwise creating it ..."
    echo "$MSG"
    sleep 2
    if [ ! -d /home/live ]; then
	    useradd -d /home/live -G audio,cdrom,floppy,plugdev,video -m -s /bin/bash live
	    echo live:live | chpasswd
	    echo "Done."
    else
	    echo "Home dir already exists."
        fi
}

config_shell_prompt () {
    # Install bash it
    echo "Configuring bashit"
    cd /home/live || exit
    sudo -u live git clone --depth=1 https://github.com/Bash-it/bash-it.git /home/live/.bash_it
    sudo -u live /home/live/.bash_it/install.sh --silent
}

###############################################################################
# Main 
###############################################################################
rm -f /var/log/log-install.txt 2>/dev/null
{
    setup
    cd "$HOME/repos/computer-labs/configurations"
    bash config_slackware.sh 
    COMPILE=NO bash ../packages/install_packages_slackware.sh
    check_live_user
    sudo -u live bash install_and_setup_doom_emacs.sh
    config_shell_prompt
    sudo -u live xfconf-query -c xfce4-panel -p "/plugins/plugin-12/timezone" --create -t string -s "America/Bogota"
} &>> /var/log/log-install.txt
