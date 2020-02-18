#!/bin/bash
echo "Update slackpkg and install security patches ..."
source $HOME/.bashrc
slackpkg -batch=on -default_answer=y update gpg
slackpkg -batch=on -default_answer=y update
slackpkg -batch=on -default_answer=y upgrade patches
slackpkg -batch=on -default_answer=y install-new # must be before upgrade-all
slackpkg -batch=on -default_answer=y upgrade-all

## sbopkg
#echo "Updating sbopkg ..."
#sbopkg -r

echo "Updating slpkg ..."
slpkg upgrade



echo "Done."
