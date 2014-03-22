#t/plugin/markdown_renderer.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Find;


my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.
my $class = 'Ado::Plugin::Auth';
can_ok($class, 'authenticated');
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
my $test_auth_url = $t->ua->server->url->path('/test/authenticateduser');
$t->get_ok('/login/ado', {Referer => $test_auth_url})->status_is(200)
  ->element_exists('section.ui.login_form form#login_form')
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

#try condition
$t->get_ok('/test/authenticateduser')->status_is(302)->header_like('Location' => qr|/login$|);

#login
$t->get_ok('/login/ado');

#get the csrf fields
my $form       = $t->tx->res->dom->at('#login_form');
my $csrf_token = $form->at('[name="csrf_token"]')->{value};
$t->post_ok(
    '/login/ado' => {DNT => 1} => form => {
        _method        => 'login/ado',
        login_name     => 'test1',
        login_password => '',
        csrf_token     => $csrf_token,
        digest =>
          Mojo::Util::sha1_hex($csrf_token . Mojo::Util::sha1_hex('test1' . 'wrong_pass')),
    }
)->status_is(401);

#try again with the right password this time
$form = $t->tx->res->dom->at('#login_form');
my $new_csrf_token = $form->at('[name="csrf_token"]')->{value};
ok($new_csrf_token ne $csrf_token, '$new_csrf_token is different');
$t->post_ok(
    '/login/ado' => {} => form => {
        _method        => 'login/ado',
        login_name     => 'test1',
        login_password => '',
        csrf_token     => $new_csrf_token,
        digest => Mojo::Util::sha1_hex($new_csrf_token . Mojo::Util::sha1_hex('test1' . 'test1')),
    }
)->status_is(302)->header_is('Location' => $test_auth_url);

# after authentication
$t->get_ok('/test/authenticateduser')->status_is(200)
  ->content_is('hello authenticated Test 1', 'hello test1 ok');

#user is Test 1
$t->get_ok('/')->status_is(200)->text_is('article.ui.main.container h1' => 'Hello, Test 1!');

#logout
$t->get_ok('/logout')->status_is(302)->header_is('Location' => $t->ua->server->url);
$t->get_ok('/')->status_is(200)->text_is('article.ui.main.container h1' => 'Hello, Guest!');


done_testing();
