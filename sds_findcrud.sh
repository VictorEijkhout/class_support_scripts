# -*- bash -*-

for r in $( cat AllRepos.txt ) ; do 
    n=$r
    n=${n%%/*}
    n=${n##*:}
    echo $n
    nexec=$( find $n -type f -exec sh -c "file {} | grep -v script | grep executable" \; )
    if [ $nexec -gt 0 ] ; then
	echo "User $n has executables

done


