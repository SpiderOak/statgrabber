#!/usr/bin/perl -w
use strict;

use lib '.';
use Pandora::Stats;

foreach (0..4) {
	Pandora::Stats::count('foo');
}

foreach (0..4) {
	Pandora::Stats::average('bar',$_);
}

foreach (0..4) {
	Pandora::Stats::accumulate('baz',$_);
}
