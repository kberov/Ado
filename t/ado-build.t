#ado-build.t
use 5.014000;
use strict;
use warnings;
use Test::More;
use File::stat;
use File::Spec::Functions qw(catdir catfile catpath);
use File::Temp qw(tempdir);
use lib(-d 'blib' ? 'blib/lib' : 'lib');
use Ado::Build;
use Mojo::Util qw(slurp);

if (not $ENV{TEST_AUTHOR}) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan(skip_all => $msg);
}
eval "use Test::Output;";
plan skip_all => "Test::Output required for this test" if $@;


my $perl = Ado::Build->find_perl_interpreter;
my $tempdir = tempdir(CLEANUP => 1);

#Build script
like(
    my $out = qx(TEST_AUTHOR=0 $perl Build.PL --install_base=$tempdir),
    qr/Creating\snew\s'Build'\sscript/,
    'running Build.PL is ok'
);

#MYMETA.json and yml
my $mymeta = slurp('MYMETA.json');
unlike($mymeta, qr/Perl\:\:Tidy/,    'ok - no $AUTHOR_TEST  build_requires');
unlike($mymeta, qr/IO::Socket::SSL/, 'ok - no $AUTHOR_TEST  requires');

#test Ado::Build it self
isa_ok(
    my $build = Ado::Build->new(
        module_name        => 'Ado',
        configure_requires => {'Module::Build' => '0.38'}
    ),
    'Module::Build'
);

subtest 'missing build element' => sub {
    ok(rename('log', 'log_'), 'no "log" dir');
    stdout_like(
        sub { $build->create_build_script(); },
        qr/Creating\snew\s'Build'\sscript/,
        'create_build_script()(no "log" dir) output ok'
    );
    my $elems = join('', qw(etc public templates));
    like(join('', @{$build->build_elements()}), qr/$elems$/, " build_elements($elems) present");

    ok(rename('log_', 'log'), 'yes "log" dir');
    done_testing();
};

stdout_like(
    sub { $build->create_build_script(); },
    qr/Creating\snew\s'Build'\sscript/,
    'create_build_script() output ok'
);

my $build_elements = [qw(etc public log templates)];

subtest 'install_paths and build elements' => sub {
    my $c      = $build->{config};
    my $prefix = $c->get('siteprefixexp');
    is_deeply(
        $build->install_path,
        {map { $_ => catdir($prefix, $_) } @$build_elements},
        'ok - install paths'
    );

    my $all_elems = join('', @{$build->build_elements()});
    for my $be (@$build_elements) {
        like($all_elems, qr/$be/, " build_element $be is present");
    }
    done_testing();
};

stdout_is(sub { $build->dispatch('build') }, "Building Ado\n", 'ACTION_build output ok');
for my $be (@$build_elements) {
    ok(-d catdir('blib', $be), "'$be' was copied to blib");
}
stdout_like(sub { $build->dispatch('submit') }, qr/^TODO/, 'ACTION_submit output ok');
stdout_is(
    sub { $build->do_create_readme },
    "Created README\nCreated README.md\n",
    'do_create_readme() output ok'
);

#check if created files look fresh.
my $t = time();
my $R = stat('README');
ok($R->ctime - $t <= 1, 'README is fresh ok');
ok($R->size > 12,       'README has size ok');
$R = stat('README.md');
ok($R->ctime - $t <= 1, 'README.md is fresh ok');
ok($R->size > 12,       'README.md has size ok');

stdout_is(sub { $build->dispatch('distmeta') }, "Created META.yml and META.json\n",
    "distmeta ok");

my $dist_out = qr/
Creating\sAdo-\d+\.\d{2}\n
Creating\sAdo-\d+\.\d{2}\.tar.gz\n/x;

stdout_like(sub { $build->dispatch('dist') }, $dist_out, 'ACTION_dist output ok');
my $directories_rx = join $/, map { $_ . '.+?' } $build->PERL_FILES;

stdout_like(
    sub { $build->dispatch('perltidy', verbose => 1) },
    qr/$directories_rx\d+\sfiles\.\.\.\nperltidy-ed\sdistribution.\n/msx,
    "perltidy ok"
);

ok(!(grep { $_ =~ /\.bak$/ } @{$build->rscan_dir($build->base_dir)}), 'no .bak files ok');

$build->install_base($tempdir);
$build->create_build_script();

stdout_like(
    sub { $build->dispatch('fakeinstall') },
    qr{Installing $tempdir},
    "fakeinstall in $tempdir ok"
);

stderr_like(
    sub { Ado::Build::_chmod(0600, catfile($tempdir, 'log', 'development.log')) },
    qr{Could not change mode for},
    'chmod development.log to 0600 ok'
);

stdout_like(
    sub { $build->dispatch('install') },
    qr{Installing $tempdir},
    "install in $tempdir ok"
);

stdout_like(
    sub { $build->dispatch('fakeuninstall') },
    qr{unlink $tempdir},
    "fakeuninstall in $tempdir ok"
);

stdout_like(
    sub { $build->dispatch('uninstall') },
    qr{unlink $tempdir},
    "uninstall in $tempdir ok"
);

done_testing();

