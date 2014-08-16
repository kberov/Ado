#t/command/adoplugin-01.t
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
my $dir     = getcwd;
my $tempdir = tempdir(CLEANUP => 1);
chdir $tempdir;
my $name        = 'MyBlog';
my $class       = "Ado::Plugin::$name";
my $decamelized = decamelize($name);

ok(my $c = $app->start("generate", "adoplugin", '-n' => $name,), 'run() ok');
my $class_file = slurp catfile($tempdir, "Ado-Plugin-$name/lib/Ado/Plugin", "$name.pm");
my $test_file  = slurp catfile($tempdir, "Ado-Plugin-$name/t/plugin",       "$decamelized-00.t");


chdir $dir;
done_testing();


