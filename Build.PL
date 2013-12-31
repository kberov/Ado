use 5.014000;
use strict;
use warnings FATAL => 'all';
use FindBin;
use lib("$FindBin::Bin/lib");
use Ado::Build;

#unset temporarily $ENV{TEST_AUTHOR}
#to generate fewer dependencies dynamically
#see http://localhost:3000/perldoc/CPAN/Meta/Spec#dynamic_config
my $author = {
    build_requires => {

        #Modules for QA - while developping
        'Perl::Tidy'          => '0',
        'Test::Output'        => '0.16',
        'Test::Perl::Critic'  => '0',
        'Test::CheckManifest' => '0',
        'Test::Pod::Coverage' => '1.08',
        'Test::Pod'           => '1.48',
        'Test::Pod::Spelling' => '0.4',
        'Devel::Cover'        => '1.08',
        'Test::Exception'     => '0.32',
        'Test::Differences'   => '0',
        'Pod::Markdown'       => '0',
    },
    configure_requires => {},
    requires           => {

        #To develop and test advanced functionality
        #This should go as "recommends" for regular users
        #when we have functionality depending on these
        'IO::Socket::SSL' => '1.957',
        'EV'              => '4.15',
        'IO::Socket::IP'  => '0.24',

        #'DBD::mysql'      => '4.025',
    },
};
my $builder = Ado::Build->new(
    module_name   => 'Ado',
    license       => 'lgpl_3_0',
    create_readme => 1,
    dist_author   => q{Красимир Беров <berov@cpan.org>},

    #release_status     => 'unstable',
    configure_requires => {
        'Module::Build' => '0.3800',
        $ENV{TEST_AUTHOR} ? (%{$$author{configure_requires}}) : (),
    },
    build_requires => {
        'Test::More' => '0',
        $ENV{TEST_AUTHOR} ? (%{$$author{build_requires}}) : (),
    },
    requires => {
        'perl'                     => '5.14.0',
        'Mojolicious'              => '4.63',
        'Mojolicious::Plugin::DSC' => '0.999',
        $ENV{TEST_AUTHOR} ? (%{$$author{requires}}) : (),
    },
    recommends           => {'DBD::SQLite' => '1.40',},
    recursive_test_files => 1,
    meta_merge           => {
        resources => {
            repository => "http://github.com/kberov/Ado",
            bugtracker => "http://github.com/kberov/Ado/issues",
        },
        keywords => [qw/Ado Mojolicious web ERP REST CMS enterprise/],
        no_index => {
            namespace =>
              ['Ado::Model', 'Ado::Command', 'Ado::Control', 'Ado::Plugin', 'Test::Ado'],
        }
    },
    script_files   => 'bin',
    add_to_cleanup => ['Ado-*', '*.bak'],
);

$builder->create_build_script();

