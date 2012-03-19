package Log::UDP::Daemon::LogFile;

use Modern::Perl;
use Data::Dumper;
use DateTime;

use Moose;
has 'conf', is => 'ro', isa => 'HashRef[Any]';

with 'Log::UDP::Daemon::StorableRole';

=head1 NAME

Log::UDP::Daemon::LogFile - Saves the incomming messages to a logfile.
Filenames have a daily datetamp.

=head1 SUBROUTINES/METHODS

=head2 open
	Not needed for now.
=cut
sub open {}

=head2 append
	Append the message to the 
=cut
sub append {
	my ($self,$msg) = @_;
	return if(not $self->validMsg($msg));
	
	my $conf = $self->conf;
	
	my $fields = $conf->{fields};
	
	my $dt = DateTime->from_epoch( epoch => $msg->{timestamp} );
	$msg->{timestamp} = $dt->ymd(' ').' '.$dt->hms(' ');
	
	# takes all the values from the hash as an array, using the fields as keys
	my @line = @{$msg}{@$fields};
	
	my $date = $dt->ymd('_');
	
	my $file = $conf->{path}.'/'.$conf->{prefix}.$date.'.'.$conf->{ext};
	
	CORE::open my $fh, '>>', $file;
	
	say $fh join("\t",@line); # closed on scope out
}

=head2 validMsg
	Verifies if the required fields are present to create a log line.
	Fields are defined in the config file.
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