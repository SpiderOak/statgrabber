#!/usr/bin/perl -w
use strict;

use Statgrabber;

foreach (0..4) {
	Statgrabber::count('foo');
}

foreach (0..4) {
	Statgrabber::average('bar',$_);
}

foreach (0..4) {
	# Test spaces, also
	Statgrabber::accumulate('b a z',$_);
}
