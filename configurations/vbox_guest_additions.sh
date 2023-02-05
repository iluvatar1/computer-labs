#!/bin/bash
install_virtualbox_guest_additions () {
    echo "Installing virtualbox guest additions"
    if ! hash vboxmanage &> /dev/null; then
	#cd /lib/modules/$(uname -r)/build
	#make oldconfig
	#make prepare
        TMPDIR=$(mktemp -d)
        mount -o loop ~/VBoxGuestAdditions.iso ${TMPDIR}
        #yes yes | /usr/bin/timeout 60s ${TMPDIR}/VBoxLinuxAdditions.run --nox11 --nochown
        umount ${TMPDIR}
        ls

        # VBOX_ADD=VirtualBox-6.1.12-139181-Linux_amd64.run
        # if [ ! -f ${VBOX_ADD} ]; then
	    #     wget -c http://download.virtualbox.org/virtualbox/6.1.12/${VBOX_ADD}
        # fi
        # yes yes | bash ${VBOX_ADD}
        # #rm ${VBOX_ADD}
    else
        echo "    -> already installed"
    fi  
}

install_virtualbox_guest_additions
