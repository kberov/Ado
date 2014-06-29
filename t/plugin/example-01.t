#t/plugin/example-01.t
# testing Ado example plugin
use Mojo::Base -strict;
use File::Basename;
use File::Spec::Functions qw(catdir updir catfile);
use Cwd qw(abs_path);
use Test::More;

BEGIN {
    $ENV{MOJO_HOME} = abs_path(catdir(dirname(__FILE__), updir, 'ado'));
    $ENV{MOJO_MODE} = 'alabala';
}
use lib("$ENV{MOJO_HOME}/lib");
use Test::Mojo;
my $t      = Test::Mojo->new('Ado');
my $app    = $t->app;
my $plugin = $app->plugin('example', {lelemale => 2});

is_deeply(
    $plugin->config,
    {   "a"        => 1,
        "bla"      => "uff",
        "lelemale" => 2
    },
    'No mode specific file - ok!'
);
done_testing;
