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
homeworkname=$1
echo "Extracting: ${homeworkname}" && echo "from users: $users" && echo

rm -rf $homeworkname
mkdir -p $homeworkname
hwgather=`pwd`/$homeworkname

function copy_hw_files () {
		    for src in "$subdir"/*.pdf "$subdir"/*.cxx "$subdir"/*.cpp ; do 
			if [ ! -z "$x" ] ; then echo " .. test file $src" ; fi
			if [ -f "$src" ] ; then 
			    if [ ! -z "$x" ] ; then echo " .. found file $src" ; fi
			    n=$( echo $src | cut -d '.' -f 1 )
			    e=$( echo $src | cut -d '.' -f 2 )
			    tgt=$u.$e
			    cp "$src" "${hwgather}/$tgt" 
			fi
		    done 2>/dev/null
}

function copy_hw_dir () {
    u=$1 ; subdir=$2 ; hwgather=$3
    rm -rf "${hwgather}/${u}_dir/${subdir}"
    cp -r "${subdir}" "${hwgather}/${u}_dir"
    if [ ! -z "$x" ] ; then
	echo " .. copy <<$subdir>> to <<$hwgather/${u}_dir>>"
    fi
}

function search_student () {
    u=$1 ; homeworkname=$2 ; altname=$3 ; hwgather=$4
	## go through all the directories of this students
    founddir="0"
    for subdir in * ; do 
	if [ -d "$subdir" ] ; then 
	    ## see if it matches (zsh test) the homework
	    normalized_name=$( echo "$subdir" | tr A-Z a-z | tr -d "_ " )
	    if [[ "$normalized_name" == *${homeworkname}* ]] ; then founddir="${subdir}" ; fi
	    if [[ "$normalized_name" == *${altname}* ]]      ; then founddir="${subdir}" ; fi
	    if [ "${founddir}" != "0" ] ; then
		echo " -- Found dir <<$u/$subdir>>" 
		if [ ! -z "${dir}" ] ; then
		    copy_hw_dir "${u}" "${subdir}" "${hwgather}"
		else
		    copy_hw_files
		fi
		break
	    fi
	fi
    done
    if [ "${founddir}" = "0" ] ; then
	echo " .. not found ${homeworkname} or ${altname}" ; found=0
    else found=1 ; fi
}

success=
failed=
for u in $users ; do 
    if [ -d "$u" ] ; then 
	if [ ! -z "$x" ] ; then echo && echo "Testing user $u"; fi
	pushd "$u" >/dev/null
	found=0
	search_student "${u}" "${homeworkname}" "${altname}" "${hwgather}"
	if [ $found -eq 0 ] ; then
	    failed="${failed} $u"
	    if [ ! -z "$altname" ] ; then 
		echo " .. $u : no homework ${homeworkname} or ${altname} found"
	    else
		echo " .. $u : no homework ${homeworkname} found"
	    fi
	else
	    success="${success} $u"
	fi
	popd >/dev/null
    fi
done | tee extract.log
echo "see extract.log"
echo "Found homework for: ${success}"
echo "Not found for: ${failed}"
