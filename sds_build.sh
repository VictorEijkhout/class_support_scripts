#!/bin/bash
################################################################
####
#### Build homework submissions.
#### Usage: sds_build.sh name
#### 
################################################################

function usage {
    echo "Usage: $0 [ -r (run) ] [ -u username ] [ -x ] homeworkname"
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

run=
users=
x=
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
    elif [ "$1" = "-x" ] ; then
	x=1 && shift
    fi
done
if [ $# -eq 0 ] ; then
    usage && exit 1
fi
# remaining argument is homework name
HW=$1
# remove tailing slash
hw=${HW%%/}
hwdir=$( pwd )/${hw}
if [ ! -d "${hwdir}" ] ; then
    echo "ERROR can not find homework directory: <<$hwdir>>; extract first?"
    usage && exit 2
else
    log=$( pwd )/${HW}.log
    # everything happens in the homework dir
    if [ ! -z ${x} ] ; then echo "Working in homework dir <<${hwdir}>>" ; fi 
fi

function build () {
    srcdir=$1
    rm -rf build 
    mkdir build
    pushd build
    export CXX=${TACC_CXX}
    cmake -D CMAKE_CXX_COMPILER=${TACC_CXX} \
	  "${srcdir}"
    make
    if [ ! -z ${run} ] ; then
	for f in * ; do
	    if [ -x $f ] ; then
		cmdline="ibrun -n 4 $f"
		echo "cmdline=$cmdline"
		eval $cmdline
	    fi
	done
    fi
    popd
}

if [ -z "$users" ] ; then
    users=$( cd "${hwdir}" && ls | grep -v .log | sed -e 's/_dir//' | sort -u )
fi
## users not all on one line: confusing
if [ ! -z ${x} ] ; then echo "Building $hw for users: $users" ; fi

for u in $users ; do 
    user=${u%%_dir}
    userdir=${u}_dir
    srcdir=${hwdir}/${userdir}
    if [ -d "${srcdir}" ] ; then
	echo && echo "==== student: ${user}"
	if [ ! -f ${userdir}/CMakeLists.txt ] ; then
	    altsrcdir=${userdir}/src
	    if [ -f ${altsrcdir}/CMakeLists.txt ] ; then
		echo "    (found CMakeLists in src)"
		srcdir=${altsrcdir}
	    fi 
	else
	    echo "WARNING can not find CMakeLists.txt for user <<$u>>" && break
	fi
	build "${srcdir}" 2>&1 | tee ${user}.log
    else
	echo "WARNING unknown user: <<$user>> not found <<$srcdir>>"
    fi
done | tee "${log}"
echo && echo "See ${log}" && echo
