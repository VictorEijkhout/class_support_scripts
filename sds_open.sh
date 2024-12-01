#!/bin/bash
################################################################
####
#### Attempt to open a git repo in a browser
####
################################################################

if [ $# -eq 0 -o $1 = "-h" ] ; then
    echo "Usage: $0 dir [dir [dir ..."
    exit 1
fi

for d in $* ; do
    if [ -d "$d" -a -d "$d/.git" ] ; then
	url=$( sds_url.sh $d )
	which open 2>/dev/null
	if [ $? -eq 0 ] ; then 
	    echo "opening $url"
	    open $url
	    sleep 1
	else
	    echo $url
	fi
    fi
done


