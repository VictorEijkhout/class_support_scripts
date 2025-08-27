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
    userdict[u] = {}
    matched = False
    readmepath = f"{u}/README.md"
    if not os.path.exists(readmepath):
        continue
    print( f"readme for: {u}" )
    with open( readmepath ) as readme:
        for line in readme:
            if not re.search(":",line): continue
            line = line.strip('\n').strip(r"\\").strip("<br/>").strip(".")
            #print(line)
            k,v = line.split(":",1); k = k.lower()
            v = v.lstrip(' ').rstrip(' ').lstrip('*').rstrip('*')
            if re.search("tacc",k):
                #print( f">> tacc: {v}" )
                userdict[u]["taccname"] = v
            elif re.search("eid",k):
                #print( f">> utid: {v}" )
                userdict[u]["eid"] = v
            elif re.search("github",k):
                #print( f">> repo: {v}" )
                userdict[u]["repo"] = v
            elif re.search("name",k):
                #print( f">> name: {v}" )
                userdict[u]["realname"] = v
            #print( f" match <<{match}>> to <<{v}>>" )
            if match and re.search( match.lower(),v.lower() ):
                #print( " .. true " )
                matched = True
    if match and not matched: continue
    try :
        realname = userdict[u]['realname']
        lastname = re.search(r'[^ ]+$',realname).group(0)
        firstname = re.sub(lastname,'',realname)
        firstname = re.sub(' ','',firstname)
        realname = f"{lastname},{firstname}"
        print( f"{realname},{userdict[u]['taccname']},{userdict[u]['eid']},{userdict[u]['repo']}" )
    except: continue
