#!/bin/bash
################################################################
####
#### Match one piece of into to another
####
################################################################

# optional argument: single user to update
if [ $# -ne 3 ] ; then
    echo "Usage: $0 incol invval outcol" && exit 0
fi
incol=$1
inval=$( echo $2 | tr A-Z a-z )
outcol=$3

infofile="AllInfo.txt"
if [ ! -f "$infofile" ] ; then
    echo "Need CSV file: AllInfo.txt" && exit 1
fi

cat $infofile \
    | tr A-Z a-z \
    | tr -d ' ' \
    | grep $inval \
    | awk -F "," -v incol=$incol -v outcol=$outcol -v inval=$inval \
	  '$(incol)~inval { print $(outcol) }'

