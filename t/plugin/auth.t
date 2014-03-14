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

#list of authentication methods in main menu
$t->get_ok('/')->status_is(200)->text_like('#authbar .item:nth-child(1)' => qr/Login using/)
  ->text_is('.simple.dropdown a.item:nth-child(1)', 'Ado')
  ->text_is('.simple.dropdown a.item:nth-child(2)', 'Facebook')

#login form in a modal box hidden also there
  ->text_is('#authbar .modal form#login_form .ui.header:nth-child(1)' => 'Login');

#same form is at /login/:auth_method
$t->get_ok('/login/ado')->status_is(200)->element_exists('section.ui.login_form form#login_form')
  ->text_is('form#login_form .ui.header:nth-child(1)' => 'Login')->element_exists('#login_name')
  ->element_exists('#login_password')->element_exists('#ado_radio')
  ->element_exists('#facebook_radio')->element_exists('.login_form script');
done_testing();
