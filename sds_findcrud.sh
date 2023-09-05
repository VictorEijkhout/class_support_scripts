# -*- bash -*-

echo "Finding executables:"
for r in $( cat AllRepos.txt ) ; do 
    n=$r
    n=${n%%/*}
    n=${n##*:}
    ## echo $n
    nexec=$( find $n -type f -exec sh -c "file \"{}\" | grep -v script | grep executable" \; | wc -l )
    if [ $nexec -gt 0 ] ; then
	echo $n
    fi
done

echo "Finding emacs autosaves:"
for r in $( cat AllRepos.txt ) ; do 
    n=$r
    n=${n%%/*}
    n=${n##*:}
    ## echo $n
    nexec=$( find $n -name \*~ -print | wc -l )
    if [ $nexec -gt 0 ] ; then
	echo $n
    fi
done

