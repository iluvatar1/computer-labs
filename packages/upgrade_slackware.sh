#!/bin/bash
#source /root/.bashrc
echo YES | slackpkg -batch=on -default_answer=y update gpg
slackpkg  -batch=on -default_answer=y update
slackpkg  -batch=on -default_answer=y install-new
slackpkg  -batch=on -default_answer=y upgrade-all

slpkg upgrade
slpkg -s alien upgrade libreoffice inkscape vlc

# Fix x2go
#perl -MCPAN -e 'recompile()'
#perl -MCPAN -e 'install DBD::SQLite'
#sbopkg -r
#removepkg /var/log/packages/perl-DBD-SQLite*
#echo 'P' | MAKEFLAGS=-j$(nproc) sbopkg -i perl-DBD-SQLite
# OR
#removepkg /var/log/packages/x2goserver*
#qg x2goserver
