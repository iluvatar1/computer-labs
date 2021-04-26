#!/usr/bin/env bash
set -euo pipefail

clone_or_update_config_repo () {
    if [ ! -d "$HOME/repos" ]; then mkdir -p $HOME/repos; fi
    cd $HOME/repos
    if [ ! -d computer-labs ]; then
        git clone https://github.com/iluvatar1/computer-labs
    else
        cd computer-labs
        git pull
    fi

}

check_live_user () {
    MSG="Checking if live user exists, otherwise creating it ..."
    echo "$MSG"
    sleep 2
    #if [ ! -d /home/live ]; then
    if [ x""==x"$(grep live /etc/passwd)" ]; then
	    useradd -d /home/live -G audio,cdrom,floppy,plugdev,video -m -s /bin/bash live
	    echo live:live | chpasswd
	    echo "Done."
    else
	    echo "User already exists."
    fi
}

config_shell_prompt () {
    # Install bash it
    echo "Configuring bashit"
    if [ ! -d /home/live/.bash_it ]; then
        cd /home/live || exit
        sudo -u live git clone --depth=1 https://github.com/Bash-it/bash-it.git /home/live/.bash_it
        sudo -u live /home/live/.bash_it/install.sh --silent
    else
        echo "Already configured"
    fi
}

install_spack () {
    MSG="-> Installing Spack"
    echo "$MSG"
    sleep 2
    if [ ! -d /home/live/repos/spack ]; then
	    mkdir /home/live/repos/
	    cd /home/live/repos/ || exit 1
	    git clone https://github.com/spack/spack
	    echo "source /home/live/repos/spack/share/spack/setup-env.sh" >> /home/live/.bashrc
	    chown -R live /home/live /home/live/repos /home/live/.bashrc
	    echo "-> Done"
    else
	    echo "-> Already installed"
    fi
}
