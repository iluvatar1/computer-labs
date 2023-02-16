#!/bin/env bash
LOGFILE="/var/log/mirror.log"
date >> "$LOGFILE"
/bin/bash /usr/local/bin/mirror-slackware-current.sh &>> "$LOGFILE"

