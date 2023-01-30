#!/bin/bash
################################################################
####
#### Attempt to open a git repo in a browser
####
################################################################

for d in * ; do
    if [ -d "$d" -a -d "$d/.git" ] ; then
	url=$( sds_url.sh $d )
	echo "opening $url"
	open $url 
    fi
done

