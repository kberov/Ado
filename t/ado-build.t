#ado-build.t
use 5.014000;
use strict;
use warnings;
use Test::More;
use Test::Output;
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

my $perl = Ado::Build->find_perl_interpreter;

#Build script
like(
    my $out = qx(TEST_AUTHOR=0 $perl Build.PL),
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
        configure_requires => {'Module::Build' => '0.38'},
    ),
    'Module::Build'
);

stdout_like(
    sub { $build->create_build_script(); },
    qr/Creating\snew\s'Build'\sscript/,
    'create_build_script() output ok'
);

#test install_paths;
my $c              = $build->{config};
my $prefix         = $c->get('siteprefixexp');
my $build_elements = [qw(etc public log templates)];
is_deeply(
    $build->install_path,
    {map { $_ => catdir($prefix, $_) } @$build_elements},
    'ok - install paths'
);
my $elems = join('', @$build_elements);
like(join('', @{$build->build_elements()}),
    qr/$elems/, " build_elements(@$build_elements) present");

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
Created\sREADME\n
Created\sREADME.md\n
Created\sMETA.yml\sand\sMETA.json\n
Creating\sAdo-\d\.d{2}\n
Creating\sAdo-\d\.d{2}\.tar.gz\n/x;

#on this test the script hangs - no idea how to fix this!
#stdout_like(sub { $build->dispatch('dist') }, $dist_out, 'ACTION_dist output ok');

stdout_like(
    sub { $build->dispatch('perltidy', verbose => 1) },
    qr/Build\.PL.+\d+\sfiles\.\.\.\nperltidy-ed\sdistribution.\n/msx,
    "perltidy ok"
);

ok(!(grep { $_ =~ /\.bak$/ } @{$build->rscan_dir($build->base_dir)}), 'no .bak files ok');


my $tempdir = tempdir(CLEANUP => 1);
$build->install_base($tempdir);

stdout_like(
    sub { $build->dispatch('fakeinstall') },
    qr{Installing $tempdir},
    "fakeinstall in $tempdir ok"
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

