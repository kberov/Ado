use 5.014000;
use strict;
use warnings FATAL => 'all';
use FindBin;
use lib("$FindBin::Bin/lib");
use Ado::Build;

my $builder = Ado::Build->new(
    module_name   => 'Ado',
    license       => 'LGPL_3_0',
    create_readme => 1,
    create_license=>1,
    dist_author   => q{Красимир Беров <berov@cpan.org>},

    #release_status     => 'unstable',
    configure_requires => {
    'Module::Build' => '0.3800',
    'Software::License' => '0.103007',
    },
    build_requires     => {'Test::More'    => '0',},
    requires           => {
        'perl'           => '5.14.0',
        Mojolicious      => '4.63',
        EV               => '4.15',
        'IO::Socket::IP' => '0.24',

        #not needed... yet
        #'IO::Socket::SSL'          => '1.957',
        'Mojolicious::Plugin::DSC' => '0.999',
    },

    recommends => {

        #Modules for QA - while developping
        'Perl::Tidy'          => '0',
        'Test::Perl::Critic'  => '0',
        'Test::CheckManifest' => '0',
        'Test::Pod::Coverage' => '1.08',
        'Test::Pod'           => '1.48',
        'Devel::Cover'        => '1.08',
        'Pod::Markdown'       => '0',

        #We cope with DBD::SQLite just fine,
        #but DBD::mysql will be also supported some day
        #'DBD::mysql'  => '4.025',
        'DBD::SQLite' => '1.40',
    },
    recursive_test_files => 1,
    meta_merge           => {
        resources => {
            repository => "http://github.com/kberov/Ado",
            bugtracker => "http://github.com/kberov/Ado/issues",
        },
        keywords => [qw/Ado Mojolicious web ERP REST CMS enterprise/]
    },

    script_files   => 'bin',
    add_to_cleanup => ['Ado-*', '*.bak'],
);

$builder->create_build_script();

