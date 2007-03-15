#!/usr/bin/python

import Statgrabber
import time

timer = Statgrabber.start('simpleclient elapsed time')

for x in range(0,5):
	Statgrabber.count('foo')

for x in range(0,5):
	Statgrabber.average('bar',x)

for x in range(0,5):
	# Test spaces, also
	Statgrabber.accumulate('b a z',x)

time.sleep(1.0)
timer.finish()
