#!/bin/bash
################################################################
####
#### This script assumes that the list of "git@git...." repos
#### are in a file ` AllRepos.txt '
####
################################################################

if [ "$1" = "-h" ] ; then
    echo "Usage: $0 # no arguments, this clones all"
    exit 0
fi

if [ $# -gt 0 ] ; then
    repos="$( cat AllRepos.txt | grep -v "^#" | grep $1 )"
else
    repos="$( cat AllRepos.txt | grep -v "^#" )"
fi
echo "Cloning: ${repos}"

for r in ${repos} ; do 
    n=$r
    n=${n%%/*}
    n=${n##*:}
    if [ ! -d $n ] ; then 
	echo "Cloning student: $n"
	git clone $r $n
	( cd $n && git config pull.rebase false )
    fi
done
