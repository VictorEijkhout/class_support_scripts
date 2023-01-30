#!/bin/bash
################################################################
####
#### Attempt to open a git repo in a browser
####
################################################################

if [ $# -eq 0 ] ; then 
    echo "Usage: $0 repo name"
    exit 1
fi

s=$1
if [ ! -d $s ] ; then 
    echo "No such repo: $s"
    exit 1
fi

cd $s
url=$( git config --get remote.origin.url )
url=$( echo $url | cut -d ":" -f 2 )
name=$( echo $url | cut -d "/" -f 1 )
repo=$( echo $url | cut -d "/" -f 2 )

# https://github.com/VictorEijkhout/class_support_scripts
echo "https://github.com/$name/$repo"


