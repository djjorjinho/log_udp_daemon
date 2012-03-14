package Log::UDP::Daemon::MongoDB;

use Modern::Perl;
use Moose;

has 'db', is => 'ro', isa => 'Any';
has 'conf', is => 'ro', isa => 'HashRef[Any]';

with 'Log::UDP::Daemon::StorableRole';

sub open {
	
}

sub append {
	
}

1;