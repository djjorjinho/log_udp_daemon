#!perl -T

use lib '../lib';

use Test::More tests => 1;

BEGIN {
    use_ok( 'Log::UDP::Daemon' ) || print "Bail out!\n";
}

diag( "Testing Log::UDP::Daemon $Log::UDP::Daemon::VERSION, Perl $], $^X" );
