#!/bin/env bash

###############################################################################
# Functions definitions
###############################################################################
# install_spack () {
#     MSG="-> Installing Spack"
#     echo "$MSG"
#     sleep 2
#     if [ ! -d /home/live/repos/spack ]; then
# 	    mkdir /home/live/repos/
# 	    cd /home/live/repos/ || exit 1
# 	    git clone https://github.com/spack/spack
# 	    echo "source /home/live/repos/spack/share/spack/setup-env.sh" >> /home/live/.bashrc
# 	    chown -R live /home/live /home/live/repos /home/live/.bashrc
# 	    echo "-> Done"
#     else
# 	    echo "-> Already installed"
#     fi
# }


###############################################################################
# Main 
###############################################################################
rm -f /var/log/log-install.txt 2>/dev/null
{
    mkdir -p $HOME/repos
    cd $HOME/repos
    git clone https://github.com/iluvatar1/computer-labs
    BDIR="$HOME/repos/computer-labs/"
    cd "$BDIR/configurations"
    bash config_slackware.sh
    cd "$BDIR/packages"
    COMPILE=NO bash install_packages_slackware.sh
    # configure as client
    cd "$BDIR/computer-room"
    # tangle the config file
    emacs --batch -l org config_computer_room.org -f org-babel-tangle
    # run the config script
    cd scripts
    echo 19 | bash bootstrap_slackware_computer_room.sh ../files CLIENT # 19 means all
} &>> /var/log/log-install.txt
