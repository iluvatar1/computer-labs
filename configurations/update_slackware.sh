#!/bin/bash
echo "Update slackpkg and install security patches ..."
slackpkg -batch=on -default_answer=y update gpg
slackpkg -batch=on -default_answer=y update
slackpkg -batch=on -default_answer=y upgrade patches
slackpkg -batch=on -default_answer=y upgrade-all
slackpkg -batch=on -default_answer=y install-new

# sbopkg
echo "Updating sbopkg ..."
sbopkg -r


echo "Done."
