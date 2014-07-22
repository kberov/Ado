#t/command/adoplugin.t
use Mojo::Base -strict;
use Test::More;
use File::Spec::Functions qw(catdir catfile catpath);
use File::Temp qw(tempdir);
use Cwd;

use Mojo::Util qw(slurp);
use Test::Mojo;
my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

my $command = 'Ado::Command::generate::adoplugin';
use_ok($command);
my $dir     = getcwd;
my $tempdir = tempdir(

    #CLEANUP => 1
);
chdir $tempdir;

ok(my $c = $app->start("generate", "adoplugin", '-n' => 'MyBlog',), 'run() ok');

chdir $dir;
done_testing();
