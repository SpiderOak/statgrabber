package Statgrabber;
use strict;

use IO::Socket;

# Some config
my $port = 9119;
my $iaddr = inet_aton('127.1');

# Connect to server
my $sock = IO::Socket::INET->new(Proto => 'udp', PeerAddr => '127.1',
				PeerPort => $port)
	or die "Creating socket: $!";

sub verify_tag {
	local $_ = shift;
	s/\s+/_/g;
	return $_;
}

sub count {
	my $tag = verify_tag(shift);
	$sock->send($tag);
}

sub average {
	my $tag = verify_tag(shift);
	my $val = shift;
	$sock->send("$tag $val");
}

sub accumulate {
	my $tag = verify_tag(shift);
	my $val = shift;
	$sock->send("$tag +$val");
}

1;
