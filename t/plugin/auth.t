#t/plugin/markdown_renderer.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Find;


my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.
my $class = 'Ado::Plugin::Auth';
can_ok($class, 'digest_auth');
can_ok($class, 'auth_local');
can_ok($class, 'auth_facebook');
can_ok($class, 'auth');
can_ok($class, 'register');
can_ok($class, 'config');


my $app = $t->app;

$t->get_ok('/authbar')->status_is(200)->content_like(qr/Login/)
  ->text_is('a.icon:nth-child(1)', 'Local')->text_is('a.icon:nth-child(2)', 'Facebook');


done_testing();
