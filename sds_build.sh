#!/bin/bash
################################################################
####
#### Build homework submissions.
#### built in the homework folder,
#### so that we can edit to fix things
####
#### Usage: sds_build.sh name
#### 
################################################################

function usage {
    echo "Usage: $0 [ -r (run) ] [ -u username ] [ -x ] homeworkname"
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage && exit 0
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
    user=$1
    echo && echo "==== student: ${user}"
    userdir="$(pwd)/${user}_dir"
    builddir=build_${user} && rm -rf ${builddir} && mkdir ${builddir}
    pushd ${builddir}
    export CXX=${TACC_CXX}
    cmake -D CMAKE_CXX_COMPILER=${TACC_CXX} \
	  "${userdir}"
    make
    if [ ! -z ${run} ] ; then
	for f in * ; do
	    if [ -x $f ] ; then
		if [ ! -z "${SLURM_JOB_UID}" ] ; then
		    cmdline="ibrun -n 4 $f"
		else
		    cmdline="./$f"
		fi
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

pushd ${hw}
for user in $users ; do 
    userdir=${user}_dir
    if [ -d "${userdir}" ] ; then
	if [ ! -f ${userdir}/CMakeLists.txt ] ; then
	    echo "WARNING can not find CMakeLists.txt for user <<$u>>" && continue
	fi
	build ${user} 2>&1 | tee ${user}.log
    else
	echo "WARNING unknown user: <<$user_dir>> not found in <<$hw>>"
    fi
done | tee "${log}"
popd
echo && echo "See ${log}" && echo
