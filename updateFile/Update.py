# encoding: utf-8
'''
Created on Jul 16, 2015

@author: stroot
'''


import os, sys
import re
import subprocess
import mycopy


## Step 1. Get candidate 
p = subprocess.Popen(['mount'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
mountInfo, err = p.communicate()
# print mountInfo

# Find all removable disk's mount point.
entries = re.findall(r'(/dev/.*?) on (.*?) ', mountInfo, re.MULTILINE)

if len(entries) == 0:
    print 'Error in getting removable disk!'
    sys.exit()

# Store all info into diskTable.
diskTable = {}
for entry in entries:
    name = entry[0]
    mountPoint = entry[1]
    diskTable[name] = mountPoint
uPath=""

for key,value in diskTable.items():
       mountRes=os.popen('cd '+value+' \n ls').read().rstrip()
       results=re.findall(r'update.csv', mountRes, re.M | re.S)
       if len(results)!=0:
           uPath=value
res=mycopy.copy(uPath)
file=open(uPath+"/result.txt",'w')
file.write(res);
file.close();


