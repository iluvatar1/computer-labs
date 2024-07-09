#!/bin/bash

config_pkg() {
    # sed -i.bck 's/-r 3600/-r 60/' /etc/default/earlyoom
    sed -i.bck 's/^EARLYOOM_ARGS.*/EARLYOOM_ARGS="-g -r 60 -m 10 -s 70 --ignore-root-user"/' /etc/default/earlyoom 
}


install_pkg() {
    TMPDIR=$(mktemp -d)
    cd $TMPDIR
    git clone https://github.com/rfjakob/earlyoom.git
    cd earlyoom
    make -n $(nproc)
    make install-initscript
}


if command -v earlyoom >/dev/null 2>&1; then
    echo "Already installed"
    config_pkg
    exit 0
fi

##########################  MAIN  #######################
install_pkg
config_pkg
