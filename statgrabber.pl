#!/usr/bin/perl -w
use strict;

use IO::Socket;
use IO::File;
use Getopt::Long;
use Sys::Syslog qw/:standard :macros/;
use POSIX qw/setsid :fcntl_h/;

# Some config;
my $port = 9119;

# Parse options
my ($nofork);
GetOptions("nofork"	=>	\$nofork);

# Start up logging, daemonize
openlog('statgrabber', 'ndelay', LOG_DAEMON);
daemonize('/var/run/statgrabber.pid') unless $nofork;

# Start up a server
my $sock = IO::Socket::INET->new(LocalPort => $port, Proto => 'udp')
	or die "IO::Socket: $!";

syslog(LOG_INFO,"Awaiting UDP messages on port $port");

# %stat_* holds the data before flushing out to ganglia once per minute
my %stat_cnt;		# For counter stats
my %stat_avg;		# For average value stats
			# each element is a list of [ sum, count ]
my %stat_acc;		# For accumulated stats (bandwidth)

$SIG{'ALRM'} = sub {
	foreach (keys %stat_cnt) {
		print "$_: $stat_cnt{$_}\n";
		system("gmetric --name $_ --value $stat_cnt{$_} --type uint32");
		# Delete stale keys
		if ($stat_cnt{$_} == 0) {
			delete $stat_cnt{$_};
			next;
		} else {
			$stat_cnt{$_} = 0;
		}
	}
	foreach (keys %stat_avg) {
		my $avg = ($stat_avg{$_}[1] ?
			   $stat_avg{$_}[0] / $stat_avg{$_}[1] : 0);
		print "$_: $avg\n";
		system("gmetric --name $_ --value $avg --type float");
		if ($stat_avg{$_}[1] == 0) {
			delete $stat_avg{$_};
			next;
		} else {
			$stat_avg{$_} = [0,0];
		}
	}
	foreach (keys %stat_acc) {
		print "$_: $stat_acc{$_}\n";
		system("gmetric --name $_ --value $stat_acc{$_} --type float");
		if ($stat_acc{$_} == 0) {
			delete $stat_acc{$_};
			next;
		} else {
			$stat_acc{$_} = 0;
		}
	}
	# Pete and repeat were sitting on a fence...
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

my ($pidpath, $pidfile);
sub daemonize {
        my $pidfilespec = shift;
        chdir '/' or die "Can't chdir to /: $!";
        open STDIN, '/dev/null' or die "Can't read /dev/null: $!";
        open STDOUT, '>/dev/null' or die "Can't write to /dev/null: $!";
        defined(my $pid = fork) or die "Can't fork: $!";
        exit if $pid;
        $pidfile = new IO::File "$pidfilespec",
		       O_WRONLY|O_TRUNC|O_NOFOLLOW|O_CREAT|O_EXCL;
        die "Can't open pid-file $pidfilespec: $!"
		unless (defined($pidfile) and $pidfile->opened);
        $pidfile->print("$$\n");
        $pidfile->flush;
        $pidpath = $pidfilespec;
        setsid or die "Can't start a new session: $!";
        open STDERR, '>&STDOUT' or die "Can't dup stdout: $!";
}

sub pidfile_cleanup {
	if (defined($pidpath)) {
		unlink $pidpath;
		$pidfile->close;
	}
}

END {
	pidfile_cleanup;
	closelog;
}
