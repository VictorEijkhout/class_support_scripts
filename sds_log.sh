#!/bin/bash

for d in * ; do
    if [ -d ${d}/.git ] ; then
	# go into a student repo directory
	pushd $d >/dev/null 
	# investigate all pdf files
	find . -name \*.pdf  -print0 | xargs -0 sds_logdate.sh 
	popd >/dev/null
    fi
done
