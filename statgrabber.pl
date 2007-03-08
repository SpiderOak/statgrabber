#!/usr/bin/perl -w
use strict;

use IO::Socket;

# Some config;
my $port = 9119;

# Start up a server
my $sock = IO::Socket::INET->new(LocalPort => $port, Proto => 'udp')
	or die "IO::Socket: $!";

print "Awaiting UDP messages on port $port\n";

# %stat_* holds the data before flushing out to ganglia once per minute
my %stat_cnt;		# For counter stats
my %stat_avg;		# For average value stats
			# each element is a list of [ sum, count ]
my %stat_acc;		# For accumulated stats (bandwidth)

$SIG{'ALRM'} = sub {
	foreach (keys %stat_cnt) {
		print "$_: $stat_cnt{$_}\n";
		system("gmetric --name $_ --value $stat_cnt{$_} --type uint32");
	}
	foreach (keys %stat_avg) {
		my $avg = $stat_avg{$_}[0] / $stat_avg{$_}[1];
		print "$_: $avg\n";
		system("gmetric --name $_ --value $avg --type float");
	}
	foreach (keys %stat_acc) {
		print "$_: $stat_acc{$_}\n";
		system("gmetric --name $_ --value $stat_acc{$_} --type float");
	}
	%stat_cnt = ();
	%stat_avg = ();
	%stat_acc = ();
	alarm 60;
};

# Once a minute, flush stats to ganglia
alarm 60;

my $running = 1;
while ($running) {
	my $data;
	$sock->recv($data, 1024) || next;	# Try again on error
	#my ($iport, $iaddr) = sockaddr_in($sock->peername);

	my ($tag, $value) = split(/\s+/,$data);
	if (defined $value && $value =~ /^\d+(.\d+)?$/) {
		# Type 2, numeric
		if (not exists $stat_avg{$tag}) {
			$stat_avg{$tag} = [$value, 1];
		} else {
			$stat_avg{$tag}[0] += $value;
			$stat_avg{$tag}[1]++;
		}
	} elsif (defined $value && $value =~ /^\+\d+(.\d+)?$/) {
		# Type 3, accumulated
		if (not exists $stat_acc{$tag}) {
			$stat_acc{$tag} = $value;
		} else {
			$stat_acc{$tag} += $value;
		}
	} elsif (defined $value) {
		# Error, ignore
		# Perhaps in the future, handle this intelligently so
		# that typos or other programmer mistakes can be more
		# easily spotted
		next;
	} else {
		# Type 1, counter
		if (not exists $stat_cnt{$tag}) {
			$stat_cnt{$tag} = 1;
		} else {
			$stat_cnt{$tag}++;
		}
	}
}
