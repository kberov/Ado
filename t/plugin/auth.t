#t/plugin/markdown_renderer.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Find;


my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.
my $class = 'Ado::Plugin::Auth';
can_ok($class, 'auth_ado');
can_ok($class, 'auth_facebook');
can_ok($class, 'auth');
can_ok($class, 'login');
can_ok($class, 'logout');
can_ok($class, 'register');
can_ok($class, 'config');


my $app = $t->app;

#list of authentication methods in main menu
$t->get_ok('/')->status_is(200)->text_like('#authbar .item:nth-child(1)' => qr/Login using/)
  ->text_is('.simple.dropdown a.item:nth-child(1)', 'Ado')
  ->text_is('.simple.dropdown a.item:nth-child(2)', 'Facebook')

#login form in a modal box hidden also there
  ->text_is('#authbar .modal form#login_form .ui.header:nth-child(1)' => 'Login')

#user is Guest
  ->text_is('article.ui.main.container h1' => 'Hello, Guest!');

#same form is at /login/:auth_method
$t->get_ok('/login/ado')->status_is(200)->element_exists('section.ui.login_form form#login_form')
  ->text_is('form#login_form .ui.header:nth-child(1)' => 'Login')->element_exists('#login_name')
  ->element_exists('#login_password')->element_exists('#ado_radio')
  ->element_exists('#facebook_radio')->element_exists('.login_form script')
  ->element_exists('input[name="_method"][checked="checked"][value$="/ado"]');

#try unexisting login method
my $help_url = $t->ua->server->url->path('/help');
$t->get_ok('/login/alabala', {Referer => $help_url})->status_is(200)
  ->element_exists_not('input[name="_method"][checked="checked"]');
$t->post_ok('/login/alabala', {Referer => $help_url})->status_is(401)
  ->text_like('.ui.error.message' => qr/of the supported login methods/);
done_testing();
