MACS="00:1A:A0:E0:A8:85 00:1A:A0:E0:A6:B9 f0:4d:a2:38:eb:2c b8:ac:6f:3a:8e:b7"
for mac in $MACS; do 
    #wakeonlan -i 192.168.123.255 $mac
    wakeonlan -i 192.168.123.255 $mac &>/dev/null
done
