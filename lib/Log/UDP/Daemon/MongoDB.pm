package Log::UDP::Daemon::MongoDB;

use Modern::Perl;
use MongoDB;
use Data::Dumper;

use Moose;
has 'con', is=>'rw', isa=>'Any';
has 'db', is => 'rw', isa => 'Any';
has 'conf', is => 'ro', isa => 'HashRef[Any]';

with 'Log::UDP::Daemon::StorableRole';

=head1 NAME

=head1 SUBROUTINES/METHODS

=head2 open
	Starts the MongoDB connection.
=cut
sub open {
	my $self = shift;
	my $conf = $self->conf;
	
	$self->con(MongoDB::Connection->new(
						host => $conf->{'host'}.':'.$conf->{'port'}
						));
	my $db = $conf->{'db'};
	$self->db($self->con->$db);
}

=head2 append
	Insert a new message in MongoDB. Specify the 'collection' in the message.
=cut 
sub append {
	my ($self,$msg) = @_;
	return if(not $self->validMsg($msg));
	
	my $collection = $msg->{'collection'} || 'main';
	delete($msg->{'collection'});
	
	my $col = $self->db->$collection;
	$col->insert($msg)
}

=head2 validMsg
	Verifies if the message has all the necessary fields to be inserted into
	the storage.
=cut
sub validMsg {
	my $self = shift;
	my $msg = shift;
	
	return 0 if(ref $msg ne 'HASH');
	
	my $man = $self->conf->{fields};
	
	for my $field (@$man) {
		return 0 if(not exists($msg->{$field}));
	}
	
	return 1;
}

1;