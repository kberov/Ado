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

    release_status     => 'unstable',
    configure_requires => {
        'Module::Build' => '0',

        #Needed only to get a Licence file in the distro
        # base directory.
        #'Software::License' => '0.103007',
    },
    build_requires => {
        'Test::More' => '0',
        ($^O =~ /Win32/i ? ('Win32::Locale' => '0') : ()),

    },
    requires => {
        Mojolicious       => '4.59',
        'IO::Socket::SSL' => '1.957',

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
my $install_base = $builder->install_base;
my $default_install_base = catdir($ENV{HOME}, 'opt', 'ado');
$builder->install_base(
    $builder->prompt(
        'Where do you want to install '
          . $builder->module_name . '?'
          . $/
          . 'We insist on some private install_base:',
        $default_install_base
    )
) unless $install_base;
$builder->install_path(etc    => catdir($builder->install_base, 'etc'));
$builder->install_path(public => catdir($builder->install_base, 'public'));

$builder->create_build_script();
