#!/bin/bash
slackpkg -batch=on -default_answer=y update gpg
slackpkg -batch=on -default_answer=y update
slackpkg -batch=on -default_answer=y upgrade-all
