#!/bin/bash
################################################################
####
#### This script assumes that the list of "git@git...." repos
#### are in a file ` AllRepos.txt '
####
################################################################

if [ $# -gt 0 ] ; then
    repos="$( cat AllRepos.txt | grep $1 )"
else
    repos="$( cat AllRepos.txt )"
fi
echo "Cloning: ${repos}"

for r in ${repos} ; do 
    n=$r
    n=${n%%/*}
    n=${n##*:}
    if [ ! -d $n ] ; then 
	echo "Cloning student: $n"
	git clone $r $n
    fi
done
