#!/bin/bash
################################################################
####
#### Extract homework submissions.
#### Usage: check_hw.sh name
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
    echo "Usage: $0 [ -h ] [ -a altname ] [ -d ] [ -x ] [ -u user ] homeworkname"
    echo "    -a : alternative homework name"
    echo "    -d : find directory by that name and copy as directory"
    exit 0
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

altname=
x=
users=$( ls )
while [ $# -gt 1 ] ; do
    if [ "$1" = "-h" ] ; then
	usage
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
    usage
fi
HW=$1
echo "Extracting: ${HW}" && echo "in users: $users" && echo

mkdir -p $HW
hwdir=`pwd`/$HW

for u in $users ; do 
    if [ -d "$u" ] ; then 
	if [ ! -z "$x" ] ; then echo && echo "Testing user $u"; fi
	pushd "$u" >/dev/null
	found=0
	## go through all the directories of this students
	for dd in * ; do 
	    if [ -d "$dd" ] ; then 
		## see if it matches (zsh test) the homework
		if [ ! -z "$x" ] ; then echo && echo " .. testing dir $dd"; fi
		stdname=$( echo "$dd" | tr A-Z a-z | tr -d "_ " )
		if [ "$stdname" == *${HW}* -o "$stdname" == "$altname" ] ; then 
		    found=1
		    if [ ! -z "$x" ] ; then echo " -- Found dir <<$u/$dd>>" ; fi 
		    if [ ! -z "${dir}" ] ; then
			src="${dd}"
			rm -rf "$hwdir/${u}_dir/$src"
			cp -r "$src" "$hwdir/${u}_dir"
			if [ ! -z "$x" ] ; then
			    echo " .. copy <<$src>> to <<$hwdir/${u}_dir>>"
			fi
		    else
			for src in "$dd"/*.pdf "$dd"/*.cxx "$dd"/*.cpp ; do 
			    if [ ! -z "$x" ] ; then echo " .. test file $src" ; fi
			    if [ -f "$src" ] ; then 
				if [ ! -z "$x" ] ; then echo " .. found file $src" ; fi
				n=$( echo $src | cut -d '.' -f 1 )
				e=$( echo $src | cut -d '.' -f 2 )
				tgt=$u.$e
				cp "$src" "$hwdir/$tgt" 
			    fi
			done 2>/dev/null
		    fi
		fi
	    fi
	done
	if [ $found -eq 0 ] ; then
	    if [ ! -z "$altname" ] ; then 
		echo " .. $u : no homework ${HW} or ${altname} found"
	    else
		echo " .. $u : no homework ${HW} found"
	    fi
	    unotfound="$unotfound $u"
	fi
	popd >/dev/null
    fi
done | tee extract.log
echo "see extract.log"
if [ ! -z "$unotfound" ] ; then
    echo "Homework not found for: $unotfound"
fi
