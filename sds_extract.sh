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
    echo "Usage: $0 [ -h ] [ -a altname ] [ -d ] [ -e ext ] [ -t ] [ -x ] [ -u user ] homeworkname"
    echo "    -a : alternative homework name"
    echo "    -d : find directory by that name and copy as directory"
    echo "    -e : only files of certain extension"
    exit 0
}

if [ $# -lt 1 -o "$1" = "-h" ] ; then
    usage
fi

altname=
ext=
trace=
x=
users=$( ls )
while [ $# -gt 1 ] ; do
    if [ "$1" = "-h" ] ; then
	usage
    elif [ "$1" = "-a" ] ; then
	shift && altname=$1 && shift
    elif [ "$1" = "-e" ] ; then
	shift && ext=$1 && shift
    elif [ "$1" = "-t" ] ; then
	trace=1 && shift
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
    if [ ! -z "${ext}" ] ; then
	for src in "$subdir"/*.${ext} ; do 
	    if [ ! -z "$x" ] ; then echo " .. test file $src" ; fi
	    if [ -f "$src" ] ; then 
		if [ ! -z "$x" ] ; then echo " .. found file $src" ; fi
		n=$( echo $src | cut -d '.' -f 1 )
		e=$( echo $src | cut -d '.' -f 2 )
		tgt=$u.$e
		cp "$src" "${hwgather}/$tgt" 
	    fi
	done 2>/dev/null
    else
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
    fi
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
	    if [ "$normalized_name" = "${homeworkname}" ] ; then
		founddir="${subdir}" ; fi
	    if [ ! -z "${altname}" ] ; then
		case ${normalized_name} in ( ${altname}* ) founddir="${subdir}" ;; esac
	    fi
	    if [ "${founddir}" != "0" ] ; then
		echo " -- Found dir <<$u/$subdir>>" 
		autosave=$( ls ${subdir}/* | grep '~$' | wc -l )
		if [ $autosave -gt 0 ] ; then
		    echo "Warning: has autosave files"
		fi
		executable=$( x=0 && for f in ${subdir}/* ; do if [ -x "$f" ] ; then x=$(( x+1 )) ; fi ; done && echo $x )
		if [ $executable -gt 0 ] ; then
		    echo "Warning: has executables"
		fi
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
	## echo " .. not found ${homeworkname} or ${altname}"
	found=0
    else found=1 ; fi
}

export success
export failed
success=
failed=
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
echo "see extract.log"
echo "Found homework for: ${success}"
echo "Not found for: ${failed}"
