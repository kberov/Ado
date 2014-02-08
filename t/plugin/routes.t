#t/plugin/routes.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
sub encode { Mojo::Util::encode $^O=~ /win/i ? 'cp866' : 'UTF-8', $_[0] }

my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.
my $app = $t->app;

is($app->plugins()->namespaces->[1], 'Ado::Plugin', 'Ado::Plugin namespace is present');

#etc/plugin/routes.conf file is loaded and routes described in the file are present
my $rs = $app->routes;
my $c  = Mojolicious::Controller->new;
my $m  = Mojolicious::Routes::Match->new(root => $rs);
$m->match($c => {method => 'GET', path => '/ado-users'});
is $m->path_for, '/ado-users', 'right GET path: /ado-users';
is_deeply($m->stack->[0], {controller => 'ado-users', action => 'list'}, 'ado-users#list ok');

$m->match($c => {method => 'POST', path => '/ado-users'});
is $m->path_for, '/ado-users', 'right POST path: /ado-users';
is_deeply($m->stack->[0], {controller => 'ado-users', action => 'list'}, 'ado-users#add ok');

done_testing();

