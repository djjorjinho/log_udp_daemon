package Log::UDP::Daemon::MongoDB;

use Modern::Perl;
use Moose;
use Data::Dumper;

has 'db', is => 'ro', isa => 'Any';
has 'conf', is => 'ro', isa => 'HashRef[Any]';

with 'Log::UDP::Daemon::StorableRole';

sub open {
	
}

sub append {
	my $self = shift;
	my $msg = shift;
	
	say Dumper($msg);
}

1;