#!/bin/bash

FILE=${1}
if [ ! -f "$FILE" ]; then
    echo "ERROR"
    echo "Usage: $0 <filename>"
    echo "filename with the format:"
    echo "IP_ADDRESS|PORT|USERNAME|OLDPASSWORD|NEWPASSWORD"
    exit 1
fi

while read line
do
    MyServer=$(echo $line | cut -d'|' -f1)
    MyPort=$(echo $line | cut -d'|' -f2)
    MyUser=$(echo $line | cut -d'|' -f3)
    MyOldPassword=$(echo $line | cut -d'|' -f4)
    MyNewPassword=$(echo $line | cut -d'|' -f5)
    echo -n "Connecting to $MyServer and changing password for $MyUser ..." 
    sshpass -p $MyOldPassword ssh -o StrictHostKeyChecking=no $MyUser@$MyServer << EOF
        echo -e "$MyOldPassword\n$MyNewPassword\n$MyNewPassword" | passwd
EOF
    #sshpass -v -p "$MyOldPassword" ssh -p $MyPort -o StrictHostKeyChecking=no $MyUser@$MyServer "echo '$MyNewPassword' | passwd --stdin $MyUser" < /dev/null
    #echo "$MyUser:$MyNewPassword" | sshpass -p "$MyOldPassword" ssh -p $MyPort -o StrictHostKeyChecking=no $MyUser@$MyServer "chpasswd"
    echo "  -> Done"
done < $FILE
