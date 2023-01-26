#!/bin/bash

for d in * ; do 
    if [ -d "$d" -a -d "$d/.git" ] ; then 
	echo "$d"
	( cd "$d"
	    git pull
	)
    fi
done
