#!/bin/bash
# Get the date of last use of the session
for ll in `x2golistsessions_root`; do 
  lastd=`echo $ll | awk -F \| '{print $11}' | awk -F T '{print $1}';`
  #Date in seconds
  lastsec=`date -d "$lastd" +%s`
  #Current date in seconds
  now=`date +%s`
  days=`echo $(( ($now - $lastsec) /60/60/24 ))`
  if [[ $days -gt $LIMIT_DAYS ]]; then
    sid=`echo $ll | awk -F \| '{print $2}'`
    echo "terminating session: $sid, $days days old, lastd: $lastd, lastsec: $lastsec, now: $now"
    x2goterminate-session $sid
  fi
done
