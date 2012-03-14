package Log::UDP::Daemon::StorableRole;

use Modern::Perl;
use Moose::Role;

# required methods
requires qw(open conf append);

1;