#!/bin/bash
################################################################
####
#### Get the submission base names of a homework
####
################################################################

# optional argument: single user to update
if [ $# -ne 2 ] ; then
    echo "Usage: $0 dir ext" && exit 0
fi
dir=$1
ext=$2

subnames=
pushd $dir
for p in *.$ext ; do
    pb=${p%%.pdf}
    echo "$p -> $pb"
    subnames="$subnames $pb"
done
popd

linecount=$( ls $dir/*.$ext | wc -l )
namecount=$( echo $subnames | wc -w )
if [ $linecount -ne $namecount ] ; then
    echo "WARNING: count mismatch line=$linecount names=$namecount"
fi
echo $subnames
