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
    echo "Usage: $0 [ -h ] [ -d ] [ -x ] [ -u user ] homeworkname"
    echo "    -d : find directory by that name and copy as directory"
    exit 0
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

x=0
users=$( ls )
while [ $# -gt 1 ] ; do
    if [ "$1" = "-h" ] ; then
	usage
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

# set nonzero for trace output
x=1

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
		if [[ "$stdname" == *${HW}* ]] ; then 
		    found=1
		    if [ ! -z "$x" ] ; then echo " -- Found dir $u/$dd" ; fi 
		    if [ ! -z "${dir}" ] ; then 
			src="$( ls -d *${dd}* 2>/dev/null \
	 				 | awk '{print $1}' )"
			if [ -z "${src}" ] ; then echo "Internal Error for student $u"
			else
			    rm -rf "$hwdir/${u}_dir/$src"
			    cp -r "$src" "$hwdir/${u}_dir"
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
	    echo " .. $u : no homework ${HW} found"
	    unotfound="$unotfound $u"
	fi
	popd >/dev/null
    fi
done | tee extract.log
echo "see extract.log"
if [ ! -z "$unotfound" ] ; then
    echo "Homework not found for: $unotfound"
fi
