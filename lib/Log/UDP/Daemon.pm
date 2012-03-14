package Log::UDP::Daemon;

use Modern::Perl;
use AnyEvent;
use AnyEvent::Handle::UDP;
use Data::Dumper;
use Moose;

has 'conf', is => 'rw', isa => 'HashRef[Any]';
has 'server', is => 'rw', isa => 'AnyEvent::Handle::UDP';
has 'storage', is => 'rw', isa => 'Any';

=head1 NAME

Log::UDP::Daemon - The great new Log::UDP::Daemon!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Log::UDP::Daemon;

    my $foo = Log::UDP::Daemon->new();
    ...

=head1 EXPORT

A list of functions that can be exported.  You can delete this section
if you don't export anything, such as for a purely object-oriented module.

=head1 SUBROUTINES/METHODS

=head2 start
	
=cut

sub start {
	my $self = shift;
	
	my $cv = AnyEvent->condvar;
	my $server = AnyEvent::Handle::UDP->new(
				bind => ['127.0.0.1',$self->conf->{server}{port}],
				on_recv => sub { $self->handler($_[0]) }
			);
	
	$self->server($server);
	
	my $driver = $self->conf->{logging}{driver};
	my $driver_package = 'Log::UDP::Daemon::'.$driver;
	my $driver_conf = $self->conf->{$driver};
	eval "use $driver_package;";
	
	my $driver_new;
	eval { $driver_new = $driver_package->can('new') };
	die $@ if($@);
	die "No driver constructor"	if(not $driver_new);
	
	$self->storage( $driver_package->new(conf=>$driver_conf) );
	
	$cv->recv();
}

sub handler {
	my $self = shift;
	say Dumper(@_);
}

=head1 AUTHOR

Daniel Lopes, C<< <dl.lopes at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-log-udp-daemon at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Log-UDP-Daemon>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Log::UDP::Daemon


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Log-UDP-Daemon>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Log-UDP-Daemon>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Log-UDP-Daemon>

=item * Search CPAN

L<http://search.cpan.org/dist/Log-UDP-Daemon/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Daniel Lopes.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of Log::UDP::Daemon
