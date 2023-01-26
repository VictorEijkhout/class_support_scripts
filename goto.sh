#!/bin/bash
################################################################
####
#### Attempt to open a git repo in a browser
####
################################################################

if [ $# -eq 0 ] ; then 
    echo "Usage: $0 studentname"
    exit 1
fi

s=$1
if [ ! -d $s ] ; then 
    echo "No such repo: $s"
    exit 1
fi

open https://github.com/$s
