#t/plugin/example-00.t
# testing Ado example plugin
use Mojo::Base -strict;
use File::Basename;
use File::Spec::Functions qw(catdir updir catfile);
use Cwd qw(abs_path);
use Test::More;

BEGIN {
    $ENV{MOJO_HOME} = abs_path(catdir(dirname(__FILE__), updir, 'ado'));
}
use lib("$ENV{MOJO_HOME}/lib");
use Test::Mojo;
my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

my $plugin = $app->plugin('example', {lelemale => 1});

ok($app->plugins->namespaces->[-1] eq 'Ado::Plugin',
    '$app->plugins->namespaces->[-1]: ' . $app->plugins->namespaces->[-1]);
is_deeply(
    $plugin->config,
    {   "a"        => 1,
        "bla"      => "off",
        "err"      => 1,
        "lelemale" => 1
    },
    'All plugin configs are merged right!'
);

my $primer = $app->plugin('primer', {lelemale => 1});
is_deeply(
    $primer->config,
    {   foo      => "bar",
        dev      => 1,
        lelemale => 1
    },
    'All plugin JSON configs are merged right!'
);

my $foo = $app->plugin('foo');
is_deeply($foo->config, {foo => "bar"}, 'Changing JSON configs extension works!');

done_testing;
