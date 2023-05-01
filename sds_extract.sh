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

for u in * ; do 
    if [ -d "$u" ] ; then 
	( cd "$u"
	    found=0
	    ## go through all the directories of this students
	    for dd in * ; do 
		if [ -d "$dd" ] ; then 
		    ## see if it matches (zsh test) the homework
		    if [[ "$( echo "$dd" | tr A-Z a-z )" == *${HW}* ]] ; then 
			found=1
			if [ ! -z "${dir}" ] ; then 
			    src=$( ls -d *${dd}* 2>/dev/null \
				| awk '{print $1}' )
			    if [ -z "${src}" ] ; then echo "Internal Error for student $u"
			    else
				rm -rf $hwdir/${u}_project/$src
				cp -r $src $hwdir/${u}_project
			    fi
			else
			    src=$( ls $dd/*.{c,cxx,cpp,py} 2>/dev/null \
				| awk '{print $1}' )
			    n=$( echo $src | cut -d '.' -f 1 )
			    e=$( echo $src | cut -d '.' -f 2 )
			    tgt=$u.$e
			    #echo "copy $src to $tgt"
			    cp $src $hwdir/$tgt
			fi
		    fi
		fi
	    done
	    if [ $found -eq 0 ] ; then
		echo "$u : no homework ${HW} found"
	    fi
	)
    fi
done
