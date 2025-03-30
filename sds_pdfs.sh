#!/bin/bash

function usage {
    echo "Usage: $0 [ -h ] [ -x ] [ -q ] [ -u user ] homework"
    echo "    -x : command execution tracing"
    echo "    -q : quiet on missing and double pdfs"
    exit 0
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

x=
quiet=
users=$( sds_users.sh )
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
homework=$1
echo "Extracting: ${homework}/pdf" && echo "from users: $users" && echo

dest=$( pwd )/${homework}/pdfs
echo "Finding pdfs in ${homework} to copy to <<$dest>>"

if [ ! -d "${homework}" ] ; then
    echo "Can not find source directory <<$homework>>"
    exit 1
fi
if [ ! -d "${dest}" ] ; then
    echo "First creating dest dir: <<${dest}>>"
    mkdir -p "${dest}"
fi

export pdf
function find_pdf () {
    pdf=""
    if [ $( ls *.pdf 2>/dev/null | wc -l ) -eq 1 ] ; then
	pdf=$( ls *.pdf | head -n 1 )
    else
	npdfs=$( find . -name \*.pdf | wc -l )
	if [ $npdfs -eq 0 ] ; then
	    echo "No pdfs found for user $user"
	elif [ $npdfs -gt 1 ] ; then
	    echo "Multiple pdfs found for user $user"
	else
	    pdf=$( find -name \*.pdf | head -n 1 )
	fi
    fi
}

export success
export failed=
success=
for user in $users ; do 
    user=${user%/}
    userdir=${homework}/${user}
    if [ ! -d "$userdir" ] ; then 
	echo "Homework ${homework} was not extracted for user ${user}"
	continue
    fi
    pushd "${userdir}" >/dev/null
    find_pdf 
    if [ ! -z "${pdf}" ] ; then
	cp "${pdf}" "${dest}/${user}.pdf"
    else
	if [ ! -z "$trace" ] ; then echo " .. failed: ${user}" ; fi
	export failed="${failed} $user"
    fi
    popd >/dev/null
done 
if [ ! -z "${failed}" ] ; then
    echo "No pdf found for: ${failed}"
fi
