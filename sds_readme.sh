#!/usr/bin/env python3
# -*- python -*-

import re
import sys
import subprocess

sys.argv = sys.argv[1:]
users = None
match = None
while len(sys.argv)>0:
    if sys.argv[0]=="-h":
        print( f"Usage: {sys.argv[0]} [ -h ] [ -u user ]" )
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
    with open( f"{u}/README.md" ) as readme:
        for line in readme:
            if not re.search(":",line): continue
            line = line.strip('\n').strip(r"\\").strip("<br/>")
            k,v = line.split(":",1); k = k.lower()
            v = v.lstrip(' ').rstrip(' ').lstrip('*').rstrip('*')
            if re.search("tacc",k):
                userdict[u]["taccname"] = v
            elif re.search("name",k):
                userdict[u]["realname"] = v
            elif re.search("eid",k):
                userdict[u]["eid"] = v
            elif re.search("github",k):
                userdict[u]["repo"] = v
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
