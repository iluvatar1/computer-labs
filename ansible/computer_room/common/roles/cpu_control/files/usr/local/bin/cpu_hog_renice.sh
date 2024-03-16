#!/bin/bash

# Define the maximum CPU usage threshold (80%)
MAX_CPU_USAGE=80

# Define the nice values for local and SSH users
LOCAL_NICE_VALUE=10
SSH_NICE_VALUE=20

# Get a list of processes using more than the threshold CPU
CPU_HOGS=$(ps aux --sort=-pcpu | awk -v max_cpu=$MAX_CPU_USAGE '$3 >= max_cpu {print $2, $3, $1, $7}')

# Loop through the CPU hog processes
while read -r PID CPU_USAGE USER TTY; do
    # Check if the user is connected via SSH
    if [[ "$TTY" =~ ^pts/ ]]; then
        # User is connected via SSH
        echo "Renicing process $PID (${USER}) to $SSH_NICE_VALUE (connected via SSH)"
	NICE_VALUE=$SSH_NICE_VALUE
    else
        # User is logged in locally
        echo "Renicing process $PID (${USER}) to $LOCAL_NICE_VALUE (local user)"
	NICE_VALUE=$LOCAL_NICE_VALUE
    fi
    date +'%Y-%m-%d %H:%M:%S.%3N'
    renice -n $NICE_VALUE -p $PID
done <<< "$CPU_HOGS"
