#!/bin/bash

if [ $# -lt 1 ] ; then
    echo "Usage: $0 homeworkname"
    exit 1
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
		    if [[ "$( echo "$dd" | tr A-Z a-z )" == ${HW}* ]] ; then 
			found=1
			src=$( ls $dd/*.{c,cxx,cpp,py} 2>/dev/null \
			    | awk '{print $1}' )
			n=$( echo $src | cut -d '.' -f 1 )
			e=$( echo $src | cut -d '.' -f 2 )
			tgt=$u.$e
			#echo "copy $src to $tgt"
			cp $src $hwdir/$tgt
		    fi
		fi
	    done
	    if [ $found -eq 0 ] ; then
		echo "$u : no homework ${HW} found"
	    fi
	)
    fi
done
