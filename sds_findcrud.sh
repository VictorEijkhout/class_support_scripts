#!/bin/bash

if [ $# -eq 0 -o $1 = "-h" ] ; then
    echo "Usage: $0 hwname"
    exit 0
fi
# subdirectory to search for each user
d=$1

# https://chatgpt.com/share/6745186a-2b18-8013-aa86-f11c22270da4
echo "Finding executables:"
for u in $( sds_users.sh ) ; do 
    echo "================ User $u"
    e=
    if [ ! -d "${u}/${d}" ] ; then continue ; fi
    for f in $( find "${u}/${d}" -type f -exec echo "{}" \; ) ; do
	if [[ -x "${f}" ]] ; then
	    ls -ld $f
   	    e="${f} ${e}"
	fi
    done
    # echo $e
    # if  [ ! -z "$e" ] ; then
    # 	echo $e
    # fi
done

echo "Finding emacs autosaves:"
for u in $( sds_users.sh ) ; do 
    nexec=$( find $u -name \*~ -print | wc -l )
    if [ $nexec -gt 0 ] ; then
	echo $u
    fi
done

