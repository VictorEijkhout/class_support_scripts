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
    | tr A-Z a-z \
    | tr -d ' ' \
    | cut -d ',' -f $incol -f $outcol \
    | awk -F ',' -v incol=$incol -v outcol=$outcol \
	  '{ if (incol>outcol) print $2 FS $1; else print $1 FS $2 }' \
    | awk -F ',' -v inval=$inval \
	  '\
	  $1~inval { print $2 }\
	  '


