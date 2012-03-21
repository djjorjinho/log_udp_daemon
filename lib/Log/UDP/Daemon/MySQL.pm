package Log::UDP::Daemon::MySQL;

use Modern::Perl;
use DBI;
use DBD::mysql;
use DateTime;
use Data::Dumper;

use Moose;
has 'con', is=>'rw', isa=>'Any';
has 'conf', is => 'ro', isa => 'HashRef[Any]';
has 'dbi',is=>'ro',writer=>'_dbi',isa=>'DBI::db';

with 'Log::UDP::Daemon::StorableRole';

=head1 NAME

=head1 SUBROUTINES/METHODS

=head2 open
	Starts the MongoDB connection.
=cut
sub open {
	my $self = shift;
	my $conf = $self->conf;
	
	#DATA SOURCE NAME
	my $dsn = "dbi:mysql:$conf->{db}:$conf->{host}:$conf->{port}";

	# PERL DBI CONNECT
	my $DBI = DBI->connect($dsn, $conf->{user},$conf->{pass})
				or die("Cant connect!");
	
	$self->_dbi($DBI);
}

=head2 append
	Insert a new message in MongoDB. Specify the 'collection' in the message.
=cut 
sub append {
	my ($self,$msg) = @_;
	return if(not $self->validMsg($msg));
	
	my $conf = $self->conf;
	
	my $collection = $msg->{'collection'} || 'main';
	delete($msg->{'collection'});
	
	my $dt = DateTime->from_epoch( epoch => $msg->{timestamp} );
	$msg->{timestamp} = $dt->ymd('-').' '.$dt->hms(':');
	
	my $fields = $conf->{fields};
	
	# create a new hash with only the defined fields => values
	my %newMsg;
	
	# fill hash with fields => vales
	@newMsg{@$fields} =  @{$msg}{@$fields};
	
	# optinal fields
	my @opt = grep {exists $msg->{$_}} @{$conf->{optional}};
	
	# fill hash with optional fields => vales
	@newMsg{@opt} =  @{$msg}{@opt};
	
	my $sql = $self->insert_sql(\%newMsg,$collection);
	
	$self->execute_sql($sql);
	
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

=head2 execute_sql
	Prepares and executes a SQL statement.
	Returns a hash with the insert id (if available) or the affected rows.
=cut
sub execute_sql
{
	my($self,$sql)=@_;
	my $query = $self->dbi->prepare($sql);
	my $res={};
	my $result = $query->execute();
	$res->{rows} = $result;
	$res->{insert_id} = $query->{insertid};
	return $res;
}

=head2 insert_sql
	Generates a SQL insert statement based on a Hash reference and a table name.
=cut
sub insert_sql
{
	my($self,$ref,$table)=@_;
	
	my $sql = "insert into $table";
	my @fields;
	my @values;
	
	for my $f(keys(%$ref))
	{
		push @fields, $f;
		push @values, "'$ref->{$f}'";
	}
	
	$sql .= '('.join(',',@fields).')';
	$sql .= 'values('.join(',',@values).')';
	
	return $sql;
}

1;