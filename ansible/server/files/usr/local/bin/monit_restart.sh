#!/bin/env bash
LOGFILE=/var/log/monit_restart.txt
/usr/bin/date >> $LOGFILE
/usr/bin/echo "$1" >> $LOGFILE
/usr/bin/echo "+-------------------+" >> $LOGFILE
/sbin/telinit 6
