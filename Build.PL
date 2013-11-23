use 5.016003;

#use 5.014002;
use strict;
use warnings FATAL => 'all';
use File::Spec::Functions qw(catdir);
use Data::Dumper;
use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

use Ado::Build;
my $builder = Ado::Build->new(
    module_name    => 'Ado',
    license        => 'LGPL_3_0',
    create_license => 1,
    dist_author    => q{Красимир Беров <berov@cpan.org>},

    #dist_version_from   => 'lib/Ado.pm',
    release_status     => 'unstable',
    configure_requires => {
        'Module::Build' => '0',

        #Need only to get a Licence file in the distro
        #'Software::License' => '0.103007',
    },
    build_requires => {
        'Test::More' => '0',
        ($^O =~ /Win32/i ? ('Win32::Locale' => '0') : ()),

    },
    requires => {
        Mojolicious                => '4.57',
        'Mojolicious::Plugin::DSC' => '0.997',
    },

    recommends => {

        #Modules for QA - while developping
        'Perl::Tidy'          => '0',
        'Test::Perl::Critic'  => '0',
        'Test::CheckManifest' => '0',
        'Test::Pod::Coverage' => '1.08',
        'Test::Pod'           => '1.48',
        'Devel::Cover'        => '1.08',

        #We cope with DBD::SQLite just fine,
        #but DBD::mysql is also supported
        'DBD::mysql'  => '4.025',
        'DBD::SQLite' => '1.40',
    },
    recursive_test_files => 1,
    meta_merge           => {
        requires  => {perl => '5.016003'},
        resources => {
            repository => "http://github.com/kberov/Ado",
            bugtracker => "http://github.com/kberov/Ado/issues",
        },
    },

    script_files   => 'bin',
    add_to_cleanup => ['Ado-*', 'log/*.log', '*.bak'],
    etc_files => {'etc/ado.conf' => 'etc/ado.conf'},
);
$builder->add_build_element($_) for (qw(etc public));
my $prefix = $builder->prefix;
my $default_prefix = catdir($ENV{HOME}, 'opt', 'ado');
$builder->prefix(
    $builder->prompt(
        'Where you want to install '
          . $builder->module_name . '?'
          . $/
          . 'We recommend some private prefix:',
        $default_prefix
    )
) unless $prefix;
$builder->install_path(etc    => catdir($builder->prefix, 'etc'));
$builder->install_path(public => catdir($builder->prefix, 'public'));

$builder->create_build_script();
