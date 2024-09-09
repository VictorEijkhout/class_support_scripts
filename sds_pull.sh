#!/bin/bash
################################################################
####
#### Update all repositories.
####
################################################################

function usage {
    echo "Usage: $0 [ -h ] [ -x ] [ -u user ]"
    exit 0
}

x=
users=$( ls )
while [ $# -gt 0 ] ; do
    if [ "$1" = "-h" ] ; then
	usage
    elif [ "$1" = "-x" ] ; then
	x=1 && shift
    elif [ "$1" = "-u" ] ; then
	shift && users=$1 && shift
    else
	echo "Unrecognized option: $1" && exit 1
    fi
done

for d in ${users} ; do 
    if [ -d "$d" -a -d "$d/.git" ] ; then 
	if [ ! -z "${x}" ] ; then echo "pulling $d" ; fi
	( cd "$d"
	  git pull >../gitmsg 2>&1
	  if [ $( cat ../gitmsg | grep "no such ref" | wc -l ) -gt 0 ] ; then
	      echo " .. main branch problem in $d"
	  fi
	)
    fi
done 2>&1 | tee pull.log
echo "see pull.log"

