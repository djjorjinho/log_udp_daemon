use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Log::UDP::Daemon',
    AUTHOR              => q{Daniel Lopes <dl.lopes@gmail.com>},
    VERSION_FROM        => 'lib/Log/UDP/Daemon.pm',
    ABSTRACT_FROM       => 'lib/Log/UDP/Daemon.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
		'YAML' => 0,
		'Log::UDP::Server' => 0,
		'File::Basename' => 0,
		'File::Spec' => 0,
		'Exception::Class::TryCatch' => 0,
		'Daemon::Generic' => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Log-UDP-Daemon-*' },
);
