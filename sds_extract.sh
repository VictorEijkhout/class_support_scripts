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

if [ $# -lt 1 ] ; then
    echo "Usage: $0 homeworkname"
    exit 1
fi
if [ "$1" = "-d" ] ; then 
  dir=1 && shift
fi
HW=$1

mkdir -p $HW
hwdir=`pwd`/$HW

# set nonzero for trace output
x=1

for u in * ; do 
    if [ -d "$u" ] ; then 
	pushd "$u" >/dev/null
	found=0
	## go through all the directories of this students
	for dd in * ; do 
	    if [ -d "$dd" ] ; then 
		## see if it matches (zsh test) the homework
		if [ ! -z "$x" ] ; then echo && echo "Testing $u/$dd"; fi
		stdname=$( echo "$dd" | tr A-Z a-z | tr -d "_ " )
		if [[ "$stdname" == *${HW}* ]] ; then 
		    found=1
		    if [ ! -z "$x" ] ; then echo " == Found dir $u/$dd" ; fi 
		    if [ ! -z "${dir}" ] ; then 
			src="$( ls -d *${dd}* 2>/dev/null \
	 				 | awk '{print $1}' )"
			if [ -z "${src}" ] ; then echo "Internal Error for student $u"
			else
			    rm -rf "$hwdir/${u}_project/$src"
			    cp -r "$src" "$hwdir/${u}_project"
			fi
		    else
			for src in $dd/*.pdf $dd/*.cxx $dd/*.cpp ; do 
			    #echo " .. test file $src"
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
	    echo "$u : no homework ${HW} found"
	    unotfound="$unotfound $u"
	fi
	popd >/dev/null
    fi
done
if [ ! -z "$unotfound" ] ; then
    echo "Homework not found for: $unotfound"
fi
