#!/bin/bash
################################################################
####
#### Build homework submissions.
#### Usage: sds_build.sh name
#### 
#### This
#### 1. creates a directory `name'
#### 2. for each directory
#### 2b. find subdirectory `name'
#### 3. take the *first* file with c/cxx/cpp/py extention
#### 4. copy that file to the central `name' directory
####
################################################################

function usage {
    echo "Usage: $0 [ -u username ] homeworkname"
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

users=
while [ $# -gt 1 ] ; do
    if [ "$1" = "-h" ] ; then
	usage && exit 0
    elif [ "$1" = "-a" ] ; then
	shift && altname=$1 && shift
    elif [ "$1" = "-x" ] ; then
	x=1 && shift
    elif [ "$1" = "-d" ] ; then
	dir=1 && shift
    elif [ "$1" = "-u" ] ; then
	shift && users=$1 && shift
    fi
done
if [ $# -eq 0 ] ; then
    usage && exit 1
fi
HW=$1
if [ ! -d "${HW}" ] ; then
    echo "ERROR can not find homework directory: <<$HW>>" && usage && exit 2
else
    cd $HW
fi
if [ -z "$users" ] ; then
    users=$( ls )
fi
echo "Building $HW for users: $users"
for u in $users ; do 
    if [ -d "$u" ] ; then
	user=${u%%_dir}
	srcdir=
	if [ -f $u/CMakeLists.txt ] ; then
	    srcdir=$u
	elif [ -f $u/src/CMakeLists.txt ] ; then
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
		) 2>&1 | tee ${user}.log
	fi
    else
	echo "WARNING unknown user: <<$u>>"
    fi
done | tee build.log
echo "see extract.log"
if [ ! -z "$unotfound" ] ; then
    echo "Homework not found for: $unotfound"
fi
