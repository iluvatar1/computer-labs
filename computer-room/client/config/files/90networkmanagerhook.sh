#!/bin/bash
 
IF=$1
STATUS=$2
 
if [ "$IF" == "eth0" ] || [ "$IF" == "eth1" ]
then
    case "$STATUS" in
        up)
            logger -s "NM Script up triggered"
            /etc/rc.d/rc.inet2 restart
            ;;
        down)
            logger -s "NM Script down triggered"
            #command2
            ;;
        pre-up)
            logger -s "NM Script pre-up triggered"
            #command3
            ;;
        post-down)
            logger -s "NM Script post-down triggered"
            #command4
            ;;
        *)
            ;;
    esac
fi
