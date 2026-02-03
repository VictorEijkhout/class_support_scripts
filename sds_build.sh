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
    echo "Usage: $0 [ -m : use mpi ] [ -r (run) ] [ -s subdir ] [ -u username ] [ -x ] homeworkname"
    echo "    -r : run after building"
    echo "    -s : build in a subdirectory"
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage && exit 0
fi

mpi=
run=
subdir=
users=
x=
while [ $# -gt 1 ] ; do
    if [ "$1" = "-h" ] ; then
	usage && exit 0
    elif [ "$1" = "-x" ] ; then
	x=1 && shift
    elif [ "$1" = "-d" ] ; then
	dir=1 && shift
    elif [ "$1" = "-m" ] ; then
	mpi=1 && shift
    elif [ "$1" = "-r" ] ; then
	run=1 && shift
    elif [ "$1" = "-s" ] ; then
	shift && subdir=$1 && shift
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
    # everything happens in the homework dir
    if [ ! -z ${x} ] ; then echo "Working in homework dir <<${hwdir}>>" ; fi 
fi

##
## build in the homework directory
##
function build () {
    user=$1 ; userdir=$2 # userdir is absolute path
    ## userdir="$(pwd)/${user}_dir"
    builddir="$(pwd)/build_${user}" && rm -rf "${builddir}" && mkdir "${builddir}"
    echo "Using build dir: <<${builddir}>>"
    pushd ${builddir}
    export CXX=${TACC_CXX}
    export CC=${TACC_CC}
    #  -D CMAKE_CXX_COMPILER=${TACC_CXX} 
    cmake \
	  "${userdir}"
    make
    if [ ! -z ${run} ] ; then
	find_executable $user $userdir
	cmdline="ibrun -n 4 $executable"
    else
	cmdline="./$executable"
    fi
    echo "cmdline=$cmdline"
    eval $cmdline
    popd
}

function find_executable () {
    user=$1 userdir=$2
    executable=$( cat "$userdir"/CMakeLists.txt | grep add_executable | cut -d '(' -f 2 )
    echo $executable
    executable=$( echo ${executable} | sed -e 's/^ *//' -e 's/ .*$//' )
    echo $executable
    echo "User $1, finding executable: $executable"
}

if [ -z "$users" ] ; then
    users="$( sds_users.sh )"
    logfile="${hwdir}/build_all.log"
else
    u=${users%%/}
    logfile="${hwdir}/build_${u}.log"
fi
## users not all on one line: confusing
##if [ ! -z ${x} ] ; then echo "Building $hw for users: $users" ; fi

pushd ${hw}
for user in $users ; do 
    user=${user%/}
    echo && echo "==== student: ${user}"
    userdir=$(pwd)/${user}
    if [ ! -z "${subdir}" ] ; then userdir="${userdir}"/"${subdir}" ; fi
    if [ -d "${userdir}" ] ; then
	if [ ! -f "${userdir}"/CMakeLists.txt ] ; then
	    echo "WARNING can not find CMakeLists.txt for user <<$user>>" && continue
	fi
	build ${user} "${userdir}" 2>&1 | tee ${user}.log
    else
	echo "WARNING unknown user: <<${userdir}>> not found in <<$hw>>"
    fi
done | tee "${logfile}"
popd
echo && echo "See ${logfile}" && echo
