#!/usr/bin/env python3
# -*- python -*-

import os
import re
import sys
import subprocess

script = sys.argv[0]
sys.argv = sys.argv[1:]
users = None
match = None
while len(sys.argv)>0:
    if sys.argv[0]=="-h":
        print( f"Usage: {script} [ -h ] [ -u user ]" )
        sys.exit(0)
    elif sys.argv[0]=="-u":
        users = sys.argv[1]
        sys.argv = sys.argv[1:]
    elif len(sys.argv)==1 and not re.match(r'\-',sys.argv[0]):
        match = sys.argv[0]
        #print( f"matching {match}" )
        break
    else:
        raise f"Unrecognized option or parameter <<{sys.argv[0]}>>"

if not users:
    command = "sds_users.sh"
    p = subprocess.Popen(command,shell=True,stdout=subprocess.PIPE)
    users = p.communicate()[0].strip().decode('utf-8')
#print(users)

userdict = {}
for u in users.split():
    userdict[u] = {"realname":"", "taccname":"", "eid":"", "repo":"", }
    readmepath = f"{u}/README.md"
    if not os.path.exists(readmepath):
        continue
    #print( f"Found readme for: {u}" )
    with open( readmepath ) as readme:
        parsed = False
        iparse = 0
        for iline,line in enumerate(readme):
            line = line.strip('\n').strip(r"\\").strip("<br/>").strip(".")
            if re.match( "#",line ): continue
            if re.search( ":",line ):
                # assume line: "Name : My Name"
                k,v = line.split(":",1); k = k.strip( r" *" ).lower()
                #print( f"{k} : {v}" )
            elif re.match( '-',line ):
                # assume line: "- My Name"
                k = ""; v = line.lstrip( r' *\-+ *' )
            else: continue
            iparse += 1
            v = v.lstrip(' ').rstrip(' ').lstrip(r'\*+').rstrip(r'\*+')
            #print( f"key <<{k}>> <<{v}>>" )
            if re.search("tacc",k) or iparse==3 :
                userdict[u]["taccname"] = v
                parsed = True
            elif re.search("eid",k) or iparse==2 :
                userdict[u]["eid"] = v
                parsed = True
            elif re.search("github",k) or iparse==4 :
                userdict[u]["repo"] = v
                parsed = True
            elif re.search("real",k) or re.search("name",k) or iparse==1 :
                userdict[u]["realname"] = v
                parsed = True
        if iline>1 and not parsed:
            print( f">> Multiline readme for {u} failed to parse" )
    #print( f"{u}: {userdict[u]}" )
    try :
        realname = userdict[u]['realname']
        namesplit= realname.rsplit(" ",1)
        firstname = namesplit[0].lstrip(' ').rstrip(' ')
        lastname  = namesplit[1].lstrip(' ').rstrip(' ')
        realname = f"{lastname} {firstname}"
        print( f"{realname},{userdict[u]['eid']},{userdict[u]['taccname']},{userdict[u]['repo']}" )
    except: continue
