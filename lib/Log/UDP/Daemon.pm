package Log::UDP::Daemon;

use Modern::Perl;
use AnyEvent;
use AnyEvent::Handle::UDP;
use YAML qw'LoadFile';
use Daemon::Generic;
use Data::Dumper;
use Moose;
use JSON::XS;
use integer;

use base 'Daemon::Generic';

has 'conf', is => 'rw', isa => 'HashRef[Any]';
has 'server', is => 'rw', isa => 'AnyEvent::Handle::UDP';
has 'storage', is => 'rw', does=>'Log::UDP::Daemon::StorableRole';
has 'json', is=>'rw', isa => 'JSON::XS';

=head1 NAME

Log::UDP::Daemon - UDP logging daemon with a storage adaptor for MongoDB, File, etc.

=cut

our $VERSION = '0.05';


=head1 SYNOPSIS

Start the daemon by using the log_udp_daemon script:

	log_udp_daemon start [optional_config_file_path]

Use the 'stop' command to shutdown the daemon.

The configuration is a YAML file that holds information like the pid file,
the udp port and the storage driver to save the log messages.
Each driver has it's own configuration so take a look at the default.yaml file.

Messages must be sent in JSON format.

You can test by issuing a netcat to your daemon's host/port:

	echo "{'hello':'world'}" | nc -w1 -u 127.0.0.1 9011

=head1 SUBROUTINES/METHODS

=head2 startServer
	Creates the UDP communication loop.
=cut

sub startServer {
	my $self = shift;
	
	my $cv = AnyEvent->condvar;
	my $server = AnyEvent::Handle::UDP->new(
				bind => ['127.0.0.1',$self->conf->{server}{port}],
				on_recv => sub {
					eval{
						$self->handler(@_);
					};
					if($@){
						print STDERR $@;
					}
					return "\cD";
				}
			);
	
	$self->server($server);
	
	$self->loadStorage();
	$self->loadJson();
	
	$cv->recv();
}

=head2 loadConfig
	Loads the configuration file.
=cut
sub loadConfig {
	my $self = shift;
	my $yaml_configfile = shift;
	my $conf;
	eval{
		$conf = LoadFile($yaml_configfile);
	};
	die($@) if($@);
	
	$self->conf($conf);
}

=head2 loadJson
	Creates an instance of the JSON::XS decoder.
=cut
sub loadJson {
	my $self = shift;
	$self->json(JSON::XS->new);
}

=head2 loadStorage
	Takes the driver class from the configuration
	and creates a new driver instance.
=cut
sub loadStorage {
	my $self = shift;
	
	my $driver = $self->conf->{logging}{driver};
	my $driver_package = 'Log::UDP::Daemon::'.$driver;
	my $driver_conf = $self->conf->{$driver};
	eval "use $driver_package;";
	
	my $driver_new;
	eval { $driver_new = $driver_package->can('new') };
	die $@ if($@);
	die "No driver constructor"	if(not $driver_new);
	
	$self->storage( $driver_package->new(conf=>$driver_conf) );
	
	$self->storage->open();
}

=head2 handler
	The method that processes what happens to the received message.
	Sends the message to the storage driver to be verified and saved.
=cut
sub handler {
	my $self = shift;
	my ($dtg,$h,$addr) = @_;

	my $msg = $self->json->decode($dtg);
	
	$self->storage->append($msg);
}

=head2 Daemon methods

=head3 start
	Starts the daemon and the udp server.
=cut

sub start {
	my $yaml_configfile = $_[1];
	my $conf = LoadFile($yaml_configfile);
	
	newdaemon(
		foreground => $conf->{daemon}{foreground}||0,
		progname => $conf->{daemon}{name},
		pidfile => $conf->{daemon}{pid},
		debug => 0,
		conf => $conf
	);
}

=head3 gd_preconfig
	
=cut
sub gd_preconfig{
	my $self = shift;
	$self->{gd_pidfile} = $self->{gd_args}{conf}{daemon}{pid};
	return ();
}

=head3 gd_run
	
=cut
sub gd_run {
	my $self = shift;
	$self->conf($self->{gd_args}{conf});
	$self->startServer();
}

=head1 AUTHOR

Daniel Lopes, C<< <dl.lopes at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests in the GitHub page.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Log::UDP::Daemon

=head1 ACKNOWLEDGEMENTS
	Thank you Modern Perl book...

=head1 LICENSE AND COPYRIGHT

Copyright 2012 Daniel Lopes.

This program is free software; you can redistribute it and/or modify it
under the terms of the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Log::UDP::Daemon
