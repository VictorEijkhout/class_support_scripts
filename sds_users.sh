#!/bin/bash

if [ ! -f AllRepos.txt ] ; then
    echo "ERROR no file <<AllRepos.txt>> in this dir"
    exit 1
fi

for r in $( cat AllRepos.txt ) ; do 
    n=$r
    n=${n%%/*}
    n=${n##*:}
    echo $n
done \
    | awk '{ u = u " " $1 } END { print u }'
