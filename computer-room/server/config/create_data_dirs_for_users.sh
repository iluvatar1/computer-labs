#!/bin/bash

for a in /home/*; do
    bname=$(basename $a)
    id -u $bname &> /dev/null
    status=$?
    #echo $bname
    #echo $status
    if [[ "0" -eq "$status" ]]; then
	for b in data01 data02; do
	    mkdir -p /mnt/local/$b/$bname	    
	    chown -R $bname.$bname /mnt/local/$b/$bname
	done
    fi
done