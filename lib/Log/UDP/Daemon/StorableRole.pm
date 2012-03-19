package Log::UDP::Daemon::StorableRole;

use Modern::Perl;
use Moose::Role;

# required methods
requires qw(open conf append);

=head1 NAME

Log::UDP::Daemon::StorableRole - all Log::UDP::Daemon storage drivers must do
this Role and implement the following methods:

open - Initiate driver connection and other operations.
conf - Sets the configuration data.
append - Appends a new message to the log.

=cut

1;