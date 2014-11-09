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
        'Perl::Tidy'          => '20140711',
        'Test::Output'        => '1.03',
        'Perl::Critic'        => '1.121',
        'Test::Perl::Critic'  => '1.02',
        'Test::CheckManifest' => '1.28',
        'Test::Pod::Coverage' => '1.10',
        'Test::Pod'           => '1.48',
        'Lingua::Ispell'      => '0',
        'Test::Pod::Spelling' => '0.4',
        'Devel::Cover'        => '1.15',
        'Test::Exception'     => '0.32',
        'Test::Differences'   => '0.62',
        'Pod::Markdown'       => '2.002',
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
    module_name => 'Ado',
    license     => 'lgpl_3_0',
    $ENV{TEST_AUTHOR} ? (create_readme => 1) : (),
    dist_author => q{Красимир Беров <berov@cpan.org>},

    #release_status     => 'unstable',
    configure_requires => {
        'Module::Build' => '0.42',
        $ENV{TEST_AUTHOR} ? (%{$$author{configure_requires}}) : (),
    },
    build_requires => {
        'Module::Build' => '0.42',
        'Test::More'    => '0',
        $ENV{TEST_AUTHOR} ? (%{$$author{build_requires}}) : (),
    },
    requires => {
        'perl'                            => '5.14.0',
        'Mojolicious'                     => '5.54',
        'Mojolicious::Plugin::DSC'        => '0.999',
        'Mojolicious::Plugin::SemanticUI' => '0.06',
        'DBIx::Simple::Class'             => '1.008',
        'Email::Address'                  => '1.905',
        'Locale::Maketext'                => '1.25',
        $ENV{TEST_AUTHOR} ? (%{$$author{requires}}) : (),

        #Default markdown renderer
        'Text::MultiMarkdown' => '1.000035',

    },
    recommends => {

        'DBD::SQLite'                 => '1.44',
        'SQL::Abstract'               => '1.78',
        'Mojolicious::Plugin::OAuth2' => '1.3',

        # Either
        'Plack'                       => '1.0030',
        'FCGI'                        => '0.74',
        'FCGI::ProcManager'           => '0.24',
        'Apache::LogFormat::Compiler' => '0',

        # or
        'Mojo::Server::FastCGI' => '0.41',
    },
    recursive_test_files => 1,
    meta_merge           => {
        resources => {
            repository => "https://github.com/kberov/Ado",
            bugtracker => "https://github.com/kberov/Ado/issues",
        },
        keywords => [qw/Ado Mojolicious realtime web ERP REST CMS enterprise/],
        no_index => {namespace => ['Ado::Model'],}
    },
    script_files   => 'bin',
    add_to_cleanup => ['Ado-*', '*.bak', 'public/doc/**/*.html', 'public/doc/**/*.html'],
);

$builder->create_build_script();

