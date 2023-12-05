#!/bin/bash

function usage {
    echo "Usage: $0 [ -h ] [ -x ] [ -q ] -d dir dest"
    echo "    -x : command execution tracing"
    echo "    -q : quiet on missing and double pdfs"
    exit 0
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

x=
dir=
quiet=
while [ $# -gt 1 ] ; do
    if [ "$1" = "-h" ] ; then
	usage
    elif [ "$1" = "-d" ] ; then
	shift && dir=$1 && shift
    elif [ "$1" = "-x" ] ; then
	x=1 && shift
    elif [ "$1" = "-q" ] ; then
	quiet=1 && shift
    fi
done

## check that the "-d dir" argument was given
if [ -z "$dir" ] ; then
    usage && exit 1
fi

## check on the destination
if [ $# -eq 0 ] ; then
    usage
fi
dest=$1
echo "Finding pdfs in ${dir} to copy to <<$dest>>"

if [ ! -d "${dir}" ] ; then
    echo "Can not find source directory <<$dir>>"
    exit 1
fi
if [ ! -d "${dest}" ] ; then
    echo "Can not find destination directory <<$dir>>"
    exit 1
fi

cd "${dir}"
for d in * ; do
    if [ -d "${d}" ] ; then
	u=${d%%_dir}
	if [ ! -z "${x}" ] ; then echo " .. investigate dir <<$d>>" ; fi
	npdf=$( find "${d}" -name \*.pdf -print | wc -l )
	if [ $npdf -eq 0 -a -z "${quiet}" ] ; then
	    echo " -- could not find pdf in <<$d>>" ; fi
	if [ $npdf -gt 1 -a -z "${quiet}" ] ; then
	    echo " -- more than one pdf in <<$d>>" ; fi
	find "${d}" -name \*.pdf -exec cp {} $dest/${u}.pdf \;
	if [ ! -z "${x}" ] ; then echo " >> written $dest/${u}.pdf" ; fi
    fi
done

