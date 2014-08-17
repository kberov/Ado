#t/command/adoplugin-00.t
use Mojo::Base -strict;
use Test::More;
use File::Spec::Functions qw(catdir catfile catpath);
use File::Temp qw(tempdir);
use Cwd;

use Mojo::Util qw(decamelize slurp);
use Test::Mojo;
my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

my $command = 'Ado::Command::generate::adoplugin';
use_ok($command);
my $dir = getcwd;
my $tempdir = tempdir(CLEANUP => 1);
chdir $tempdir;
my $name        = 'MyBlog';
my $class       = "Ado::Plugin::$name";
my $decamelized = decamelize($name);

ok(my $c = $app->start("generate", "adoplugin", '-n' => $name), 'run() ok');
my $class_file  = slurp catfile($tempdir, "Ado-Plugin-$name/lib/Ado/Plugin", "$name.pm");
my $test_file   = slurp catfile($tempdir, "Ado-Plugin-$name/t/plugin",       "$decamelized-00.t");
my $build_file  = slurp catfile($tempdir, "Ado-Plugin-$name/Build.PL");
my $config_file = slurp catfile($tempdir, "Ado-Plugin-$name/etc/plugins",    "$decamelized.conf");
like($class_file  => qr/register.+initialise/sm,     'Class code is ok');
like($class_file  => qr/$class - an A.+foooooo/,     'Class documentation is ok');
like($test_file   => qr/$class.+isa_ok/sm,           'Test file is ok');
like($build_file  => qr/Ado::BuildPlugin.+$class/sm, 'Build.PL file is ok');
like($config_file => qr/$decamelized/sm,             'Configuration file is ok');

unshift @INC, catdir($tempdir, "Ado-Plugin-$name", 'lib');

use_ok("Ado::Plugin::$name");
isa_ok(my $plugin = $class->new->register($t->app, {'аз' => 'ти'}),
    'Ado::Plugin', "$name ISA Ado::Plugin");
is($plugin->config->{'аз'}, 'ти', '$name configuration works');
chdir "Ado-Plugin-$name";
{
    local $SIG{__WARN__} = sub {
        return if ok $_[0] =~ m/
    'MANIFEST\sfile'|
    'Build'.+'Ado-Plugin-$name'|
    /smx, 'warnings from Build.PL ok';
        warn @_;
    };
    require_ok("Build.PL");
}

chdir $dir;
done_testing();
