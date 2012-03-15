package Log::UDP::Daemon::MongoDB;

use Modern::Perl;
use MongoDB;
use Data::Dumper;

use Moose;
has 'con', is=>'rw', isa=>'Any';
has 'db', is => 'rw', isa => 'Any';
has 'conf', is => 'ro', isa => 'HashRef[Any]';

with 'Log::UDP::Daemon::StorableRole';

sub open {
	my $self = shift;
	my $conf = $self->conf;
	
	$self->con(MongoDB::Connection->new(
						host => $conf->{'host'}.':'.$conf->{'port'}
						));
	my $db = $conf->{'db'};
	$self->db($self->con->$db);
}

sub append {
	my $self = shift;
	my $msg = shift;
	
	my $collection = $msg->{'collection'} || 'main';
	delete($msg->{'collection'});
	
	my $col = $self->db->$collection;
	$col->insert($msg)
}

1;