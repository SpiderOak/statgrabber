#!/usr/bin/perl -w
use strict;

use Statgrabber;

my $timer = Statgrabber::start('simpleclient elapsed time');

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

sleep(1);

$timer->finish();
