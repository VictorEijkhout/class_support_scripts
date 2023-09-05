#!/bin/bash
################################################################
####
#### This script assumes that the list of "git@git...." repos
#### are in a file ` AllRepos.txt '
####
################################################################

for r in $( cat AllRepos.txt ) ; do 
    n=$r
    n=${n%%/*}
    n=${n##*:}
    echo $n
    if [ ! -d $n ] ; then 
	echo "Cloning student: $n"
	git clone $r $n
    fi
done
