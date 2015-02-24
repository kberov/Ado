#t/plugin/example-00.t
# testing Ado example plugin
use Mojo::Base -strict;
use File::Basename;
use File::Spec::Functions qw(catdir updir catfile);
use Cwd qw(abs_path);
use Test::More;

BEGIN {
    $ENV{MOJO_HOME} = abs_path(catdir(dirname(__FILE__), updir, 'ado'));
    $ENV{MOJO_CONFIG} = abs_path(catfile($ENV{MOJO_HOME}, '../../etc/ado.conf'));
}
use lib("$ENV{MOJO_HOME}/lib");
use Test::Mojo;
my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

isa_ok($app->plugin('ado_helpers'), 'Ado::Plugin::AdoHelpers');
my $plugin = $app->plugin('example', {lelemale => 1});

ok($app->plugins->namespaces->[-1] eq 'Ado::Plugin',
    '$app->plugins->namespaces->[-1]: ' . $app->plugins->namespaces->[-1]);
isnt($app->home,        $app->ado_home, '$app->home is not $app->ado_home');
isnt($plugin->home_dir, $app->ado_home, '$plugin->home_dir is not $app->ado_home');
is($plugin->home_dir, $ENV{MOJO_HOME}, '$plugin->home_dir is $MOJO_HOME');
is( $plugin->config_dir,
    catdir($ENV{MOJO_HOME}, 'etc', 'plugins'),
    '$plugin->config_dir is $MOJO_HOME/etc/plugins'
);
is($app->home->rel_dir('public'),    $app->static->paths->[0],   'app static path is first');
is($app->ado_home->rel_dir('public'),    $app->static->paths->[1],   'Ado static path is second');
is($app->home->rel_dir('templates'), $app->renderer->paths->[0], 'app renderer path is first');
is($app->ado_home->rel_dir('templates'), $app->renderer->paths->[1],
    'Ado renderer path is second');

is_deeply(
    $plugin->config,
    {   "a"        => 1,
        "bla"      => "off",
        "err"      => 1,
        "lelemale" => 1,
        routes     => [{route => '/a', to => 'a#b', over => 'a'}],

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
