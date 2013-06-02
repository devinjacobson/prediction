#!/usr/bin/python

# joins values (column numbers >= 2) if keys (column number == 1) are identical

import math
import sys
import re
a = sys.stdin.readlines()

keys = []
vals = []
nrs  = []

for b in a:
    if b.strip() != '':
	z = re.split(r'"', b.strip())
	y = []
	key = z[1]
	val = z[2].strip()
#	print 'key: ' + key
#	print 'val: ' + val
	if not key in keys:
	    keys.append(key)
	    vals.append(val)
	    nrs.append(1)
	else:
	    ind = keys.index(key)
	    vals[ind] = vals[ind] + ' ' + val
	    nrs[ind] = nrs[ind] + 1

for ind in range(0,len(keys)):
   key = keys[ind]
   val = vals[ind]
   nr = nrs[ind]
   if nr == 3:
        print val
