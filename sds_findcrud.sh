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
    e=
    if [ ! -d "${u}/${d}" ] ; then continue ; fi
    m=
    for f in $( find "${u}/${d}" -type f -exec echo "{}" \; ) ; do
	if [[ -x "${f}" ]] ; then
	    if [ -z "$m" ] ; then
		echo "================ $u"
		m=1
	    fi
	    ls -ld $f
   	    e="${f} ${e}"
	fi
    done
    # echo $e
    # if  [ ! -z "$e" ] ; then
    # 	echo $e
    # fi
done
echo

echo "Finding emacs autosaves:"
for u in $( sds_users.sh ) ; do 
    if [ ! -d "${u}/${d}" ] ; then continue ; fi
    nexec=$( find $u/$d -name \*~ -print | wc -l )
    if [ $nexec -gt 0 ] ; then
	echo "================ $u"
	echo "$nexec"
    fi
done
echo

echo "Multiple sources:"
for u in $( sds_users.sh ) ; do 
    if [ ! -d "${u}/${d}" ] ; then continue ; fi
    nsources=$( find $u/$d -name \*.cpp -print | wc -l )
    if [ $nsources -gt 1 ] ; then
	echo "================ $u"
	echo "$nsources"
    fi
done
echo
