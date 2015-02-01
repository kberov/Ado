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
$m->match($c => {method => 'GET', path => '/'});
is $m->path_for->{path}, '/', 'right GET path: /';
is_deeply($m->stack->[0], {controller => 'Default', action => 'index'}, 'default#index ok');

$m->match($c => {method => 'PUT', path => '/default/form/1'});
is $m->path_for->{path}, '/default/form/1', 'right PUT path: /default/form/1';
is_deeply($m->stack->[0], {controller => 'default', action => 'form', id => 1},
    'default#form ok');

$m->match($c => {method => 'POST', path => '/default'});
is $m->path_for->{path}, '/default', 'right POST path: /default';
is_deeply($m->stack->[0], {controller => 'default', action => 'index'}, 'default#form ok');

is $app->routes->lookup('perldocmodule')->to->{module}, 'Ado/Manual',
  '"/perldoc" :module is "Ado/Manual".';


done_testing();

