#!/bin/bash
################################################################
####
#### List homework submissions.
#### Usage: sds_list.sh name
#### 
################################################################

function usage {
    echo "Usage: $0 [ -u username ] homeworkname"
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

run=
users=
while [ $# -gt 1 ] ; do
    if [ "$1" = "-h" ] ; then
	usage && exit 0
    elif [ "$1" = "-u" ] ; then
	shift && users=$1 && shift
    fi
done
if [ $# -eq 0 ] ; then
    usage && exit 1
fi
# remaining argument is homework name
HW=$1
# remove tailing slash
HW=${HW%%/}
if [ ! -d "${HW}" ] ; then
    echo "ERROR can not find homework directory: <<$HW>>" && usage && exit 2
else
    cd $HW
fi
if [ -z "$users" ] ; then
    users=$( ls )
fi
## users not all on one line: confusing
## echo "Building $HW for users: $users"
for u in $users ; do 
    if [ -d "$u" ] ; then
	user=${u%%_dir}
	( find $u -name \*.c -o -name \*.cpp -o -name \*.cxx ) | xargs cat 
    else
	echo "WARNING unknown user: <<$u>>"
    fi
done | tee ${log}
echo && echo "See ${log}" && echo
