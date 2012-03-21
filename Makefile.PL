use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Log::UDP::Daemon',
    AUTHOR              => q{Daniel Lopes <dl.lopes@gmail.com>},
    VERSION_FROM        => 'lib/Log/UDP/Daemon.pm',
    ABSTRACT_FROM       => 'lib/Log/UDP/Daemon.pm',
    CONFIGURE_REQUIRES => {
    	"ExtUtils::MakeMaker" => "6.30"
    },
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
		'YAML' => 0,
		'AnyEvent::Handle::UDP' => 0,
		'File::Basename' => 0,
		'File::Spec' => 0,
		'Exception::Class::TryCatch' => 0,
		'Daemon::Generic' => 0,
		'Moose' => 0,
		'JSON::XS' => 0,
		'Modern::Perl' => 0,
		'DBD::mysql' => 0,
		'DateTime' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Log-UDP-Daemon-*' },
);
