#t/command/adoplugin.t
use Mojo::Base -strict;
use Test::More;
use File::Spec::Functions qw(catdir catfile catpath);
use File::Temp qw(tempdir);
use Cwd;

use Mojo::Util qw(decamelize slurp);
use Test::Mojo;
my $dir = getcwd;

my $tempdir = tempdir(CLEANUP => 1);

TODO: {
    my $command = 'Ado::Command::generate::crud';

    use_ok($command);
    chdir $tempdir;

    #unshift @INC, catdir($tempdir, 'lib');
    #local $ENV{MOJO_HOME} = $tempdir;
    #my $t   = Test::Mojo->new('Ado');
    #my $app = $t->app;

}

chdir $dir;
done_testing();
