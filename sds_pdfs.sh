#!/bin/bash

function usage {
    echo "Usage: $0 [ -h ] [ -x ] [ -q ] [ -u user ] homeworkname"
    echo "    -x : command execution tracing"
    echo "    -q : quiet on missing and double pdfs"
    exit 0
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

x=
quiet=
users=$( ls )
while [ $# -gt 1 ] ; do
    if [ "$1" = "-h" ] ; then
	usage
    elif [ "$1" = "-a" ] ; then
	shift && altname=$1 && shift
    elif [ "$1" = "-u" ] ; then
	shift && users=$1 && shift
    elif [ "$1" = "-x" ] ; then
	x=1 && shift
    elif [ "$1" = "-q" ] ; then
	quiet=1 && shift
    else
	echo "Unrecognized option: <<$1>>" && exit 1
    fi
done
if [ $# -eq 0 ] ; then
    usage
fi
homeworkname=$1
echo "Extracting: ${homeworkname}/pdf" && echo "from users: $users" && echo

dest=$(pwd)/$1
echo "Finding pdfs in ${dir} to copy to <<$dest>>"

if [ ! -d "${dir}" ] ; then
    echo "Can not find source directory <<$dir>>"
    exit 1
fi
if [ ! -d "${dest}" ] ; then
    echo "First creating dest dir: <<${dest}>>"
    mkdir -p "${dest}"
fi

function find_pdf () {
    d=$1 ; dest=$2
    u=${d%%_dir}
    if [ $( ls ${d}/*.pdf >/dev/null | wc -l ) -eq 1 ] ; then
	cp ${d}/*.pdf ${dest}/${u}.pdf
	if [ ! -z "${x}" ] ; then
	    echo " >> written root pdf to ${dest}/${u}.pdf" ; fi
    else
	npdf=$( find "${d}" -name \*.pdf -print | wc -l )
	if [ $npdf -eq 0 -a -z "${quiet}" ] ; then
	    echo " -- could not find pdf in <<$d>>" ; fi
	if [ $npdf -gt 1 -a -z "${quiet}" ] ; then
	    echo " -- more than one pdf in <<$d>>" ; fi
	find "${d}" -name \*.pdf -exec cp {} $dest/${u}.pdf \;
    fi
}

export success
export failed
success=
for user in $users ; do 
    user=${user%/}
    if [ -d "$user" -a -d "${user}/.git" ] ; then 
	if [ ! -z "$trace" ] ; then echo && echo "Testing user $user"; fi
	pushd "$user" >/dev/null
	found=0
	search_student "${user}" "${homeworkname}" "${altname}" "${hwgather}"
	if [ $found -eq 0 ] ; then
	    if [ ! -z "$trace" ] ; then echo " .. failed: ${user}" ; fi
	    export failed="${failed} $user"
	else
	    if [ ! -z "$trace" ] ; then echo " .. success: ${user}" ; fi
	    export success="${success} $user"
	fi
	popd >/dev/null
    fi
done 
