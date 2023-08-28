#!/bin/bash
################################################################
####
#### Attempt to open a git repo in a browser
####
################################################################

if [ $# -eq 0 ] ; then
    echo "Usage: $0 dir"
    exit 1
fi

d=$1
if [ -d "$d" -a -d "$d/.git" ] ; then
    url=$( sds_url.sh $d )
    echo "opening $url"
    open $url 
fi


