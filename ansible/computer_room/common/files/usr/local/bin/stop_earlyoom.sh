#!/bin/bash

if [ -f /var/run/earlyoom.pid ]; then
    pid=$(cat /var/run/earlyoom.pid)
    kill $pid
    rm -f /var/run/earlyoom.pid
#else
fi
pkill -f earlyoom
