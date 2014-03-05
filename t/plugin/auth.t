#t/plugin/markdown_renderer.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Find;


my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.
my $class = 'Ado::Plugin::Auth';
can_ok($class, 'digest_auth');
can_ok($class, 'auth_ado');
can_ok($class, 'auth_facebook');
can_ok($class, 'auth');
can_ok($class, 'register');
can_ok($class, 'config');


my $app = $t->app;

$t->get_ok('/')->status_is(200)->text_like('main .menu .simple.dropdown' => qr/Login/)
  ->text_is('.simple.dropdown a:nth-child(1)', 'Ado')
  ->text_is('.simple.dropdown a:nth-child(2)', 'Facebook');


done_testing();
