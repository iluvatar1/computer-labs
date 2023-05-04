#!/bin/bash

usage(){
    echo "Error: filename $FNAME does not exists"
    echo "USAGE: script.sh FILENAME.csv"
}
info() {
    echo "This script reads a csv exported from a dninfo unal excel list."
    echo "The input csv must have the fields:"
    echo "\"LASTNAME, NAME\",  DOCUMENTO,  PLAN, OBSERVACION, CORREO"
    echo "Then this script will print:"
    echo "username,password,fullname"
    echo "Then you will we able to use that info as input for the create accounts script. "
}

FNAME="${1}"

if [ ! -f "$FNAME" ]; then
    usage
    info
    exit 1
fi

TMPFNAME=$(mktemp)
# remove header
tail -n +2 "$FNAME" > "$TMPFNAME"
# Replace first comma to easy parsing : "LASTNAME, NAME", DOC, asds
sed -i 's/,//' "$TMPFNAME"

while IFS=',' read -r fullname password plan observation email
do
    if [[ -z "$email" ]]; then continue; fi
    username=${email%@*}
    comment="$fullname"
    echo "${username},${password},${fullname}"
done < "$TMPFNAME"
