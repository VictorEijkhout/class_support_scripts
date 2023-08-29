#!/bin/bash
################################################################
####
#### Update all repositories.
####
################################################################

# optional argument: single user to update
if [ $# -eq 1 ] ; then
    targetdir=$1
fi

for d in * ; do 
    # if no specific target, or this is the specific target
    if [ -z "$targetdir" -o "$d" = "$targetdir" ] ; then
	if [ -d "$d" -a -d "$d/.git" ] ; then 
	    echo "$d"
	    ( cd "$d"
	      git pull >../gitmsg 2>&1
	      if [ $( cat ../gitmsg | grep "no such ref" | wc -l ) -gt 0 ] ; then
		  echo " .. main branch problem in $d"
	      fi
	    )
	fi
    fi
done 2>&1 | tee pull.log
echo "see pull.log"

