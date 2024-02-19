#!/bin/bash
################################################################
####
#### Build homework submissions.
#### Usage: sds_build.sh name
#### 
################################################################

function usage {
    echo "Usage: $0 [ -r (run) ] [ -u username ] homeworkname"
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

run=
users=
while [ $# -gt 1 ] ; do
    if [ "$1" = "-h" ] ; then
	usage && exit 0
    elif [ "$1" = "-x" ] ; then
	x=1 && shift
    elif [ "$1" = "-d" ] ; then
	dir=1 && shift
    elif [ "$1" = "-r" ] ; then
	run=1 && shift
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
    log=$( pwd )/${HW}.log
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
	echo && echo "==== student: ${user}"
	srcdir=
	if [ -f $u/CMakeLists.txt ] ; then
	    srcdir=$u
	elif [ -f $u/src/CMakeLists.txt ] ; then
	    echo "    (found CMakeLists in src)"
	    srcdir=$u/src
	fi
	if [ -z "$srcdir" ] ; then
	    echo "WARNING can not find CMakeLists.txt for user <<$u>>"
	else
	    ( rm -rf build \
		  && mkdir build \
		  && cd build \
		  && cmake ../${srcdir} \
		  && make \
		  && if [ ! -z ${run} ] ; then \
		      for f in * ; do \
			  if [ -x $f ] ; then \
			      ibrun -n 4 $f \
			      ; fi \
		      ; done \
		  ; fi \
		) 2>&1 | tee ${user}.log
	fi
    else
	echo "WARNING unknown user: <<$u>>"
    fi
done | tee ${log}
echo && echo "See ${log}" && echo
