#!/usr/bin/env python3
# -*- python -*-

import re
import subprocess

command = "sds_users.sh"
p = subprocess.Popen(command,shell=True,stdout=subprocess.PIPE)
users = p.communicate()[0].strip().decode('utf-8')
#print(users)
userdict = {}
for u in users.split():
    userdict[u] = {}
    with open( f"{u}/README.md" ) as readme:
        for line in readme:
            if not re.search(":",line): continue
            line = line.strip('\n').strip(r"\\").strip("<br/>")
            #print(line)
            k,v = line.split(":",1); k = k.lower()
            v = v.lstrip(' ').rstrip(' ')
            if re.search("tacc",k):
                userdict[u]["taccname"] = v
            elif re.search("name",k):
                userdict[u]["realname"] = v
            elif re.search("eid",k):
                userdict[u]["eid"] = v
            elif re.search("github",k):
                userdict[u]["repo"] = v
    #print( userdict[u] )
    try :
        realname = userdict[u]['realname']
        lastname = re.search(r'[^ ]+$',realname).group(0)
        firstname = re.sub(lastname,'',realname)
        firstname = re.sub(' ','',firstname)
        realname = f"{lastname},{firstname}"
        print( f"{realname},{userdict[u]['taccname']},{userdict[u]['eid']},{userdict[u]['repo']}" )
    except: continue
