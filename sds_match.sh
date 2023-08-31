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
inval=$2
outcol=$3

infofile="AllInfo.txt"
if [ ! -f "$infofile" ] ; then
    echo "Need CSV file: AllInfo.txt" && exit 1
fi

cat $infofile \
    cut -d ',' -f $1,$3 \
    awk -F ',' -v inval=$2 \
    '$1~inval /print $2/'


