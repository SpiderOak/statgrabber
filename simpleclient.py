#!/usr/bin/python

import Statgrabber

for x in range(0,5):
	Statgrabber.count('foo')

for x in range(0,5):
	Statgrabber.average('bar',x)

for x in range(0,5):
	# Test spaces, also
	Statgrabber.accumulate('b a z',x)
