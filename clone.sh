#!/bin/bash

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


