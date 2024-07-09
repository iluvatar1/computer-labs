#!/bin/env bash
LOGFILE=/var/log/monit_restart.txt
/usr/bin/date >> $LOGFILE
/usr/bin/echo "$1" >> $LOGFILE
/usr/bin/echo "+-------------------+" >> $LOGFILE
# See https://www.thegeekstuff.com/2008/12/safe-reboot-of-linux-using-magic-sysrq-key/
/sbin/reboot -f &
sleep 10
echo 1 > /proc/sys/kernel/sysrq
echo b > /proc/sysrq-trigger
# Sometimes this work but now is superceded by the previous
/sbin/reboot -f &
/usr/bin/sleep 5
/sbin/telinit 6 &
/sbin/telinit 6 &
/sbin/init 6 &
