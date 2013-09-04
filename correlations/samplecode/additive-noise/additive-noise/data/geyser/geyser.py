#!/usr/bin/python

# geyser data are in the form "w_t, d_t"
# if d_t == 2.0000000, 3.0000000, 4.0000000 then it is not measured precisely
#
# we calculate the interval between two eruptions i_t = w_{t+1} - d_t
#
# we output precise data in the form "d_t i_t d_{t+1}"

import math
import sys
import re
a = sys.stdin.readlines()

w = []
d = []
i = []

t = 0
for b in a:
    if b.strip() != '':
	z = re.split(r'\s', b.strip())
	w.append(z[0])
	d.append(z[1])
	t = t + 1
T = t

for t in range(0,T-1):
	i.append(float(w[t+1]) - float(d[t]))
	if d[t][1:] != '.0000000' and d[t+1][1:] != '.0000000':
		print d[t],i[t], d[t+1]
#	if d[t][1:] != '.0000000':
#		print d[t], i[t]
