#t/plugin/auth-01.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Find;

my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.
#list of authentication methods in main menu
$t->get_ok('/')->status_is(200)->text_is('#authbar .item:nth-child(1)' => 'Sign in')
  ->text_is('.simple.dropdown a.item:nth-child(1)', '')
  ->text_is('.simple.dropdown a.item:nth-child(2)', '')

#login form in a modal box hidden also there
  ->text_is('#authbar .modal form#login_form .ui.header:nth-child(1)' => 'Login')

#user is Guest
  ->text_is('article.ui.main.container h1' => 'Hello Guest,');

#same form is at /login/:auth_method
my $test_auth_url = $t->ua->server->url->path('/test/authenticateduser');
$t->get_ok('/login/ado', {Referer => $test_auth_url})->status_is(200)
  ->element_exists('section.ui.login_form form#login_form')
  ->text_is('form#login_form .ui.header:nth-child(1)' => 'Login')->element_exists('#login_name')
  ->element_exists('#login_password')->element_exists('#ado_radio')

  #->element_exists('#google_radio')->element_exists('.login_form script')
  ->element_exists('input[name="_method"][checked="checked"][value$="/ado"]');

#try unexisting login method
my $help_url = $t->ua->server->url->path('/help');
$t->get_ok('/login/alabala', {Referer => $help_url})->status_is(401)
  ->element_exists_not('input[name="_method"][checked="checked"]');
$t->post_ok('/login/alabala', {Referer => $help_url})->status_is(401)
  ->text_like('.ui.error.message' => qr/of the supported login methods/);

#try condition (redirects to /login url)
my $login_url =
  $t->get_ok('/test/authenticateduser')->status_is(302)->header_like('Location' => qr|/login$|)
  ->tx->res->headers->header('Location');

#login after following the Location header (redirect)
$t->get_ok($login_url);

#get the csrf fields
my $form       = $t->tx->res->dom->at('#login_form');
my $csrf_token = $form->at('[name="csrf_token"]')->{value};
my $form_hash  = {
    _method        => 'login/ado',
    login_name     => 'test1',
    login_password => '',
    csrf_token     => $csrf_token,
    digest => Mojo::Util::sha1_hex($csrf_token . Mojo::Util::sha1_hex('test1' . 'wrong_pass')),
};
$t->post_ok($login_url => {} => form => $form_hash)->status_is(401);

#try with wrong (unchanged) csrf token
$t->post_ok($login_url => {DNT => 1} => form => $form_hash)->status_is(403, 'Wrong csrf_token')
  ;    #403 Forbidden

#try with no user passed
$t->get_ok($login_url);
delete $form_hash->{login_name};
$form_hash->{csrf_token} = $t->tx->res->dom->at('#login_form [name="csrf_token"]')->{value};
$form_hash->{digest} =
  Mojo::Util::sha1_hex($form_hash->{csrf_token} . Mojo::Util::sha1_hex('' . 'wrong_pass'));
$t->post_ok($login_url => {} => form => $form_hash)->status_is(401, 'No login_name');

#try with no data
$t->post_ok($login_url)->status_is(401, 'No $val->has_data');

#try with unexisting user
$t->get_ok($login_url);
$form_hash->{login_name} = 'alabala';
$form_hash->{csrf_token} = $t->tx->res->dom->at('#login_form [name="csrf_token"]')->{value};
$form_hash->{digest} =
  Mojo::Util::sha1_hex($form_hash->{csrf_token} . Mojo::Util::sha1_hex('' . 'wrong_pass'));
$t->post_ok($login_url => {} => form => $form_hash)->status_is(401, 'No such user $login_name')
  ->text_is('#error_login',      'Wrong credentials! Please try again!')
  ->text_is('#error_login_name', "No such user '$form_hash->{login_name}'!");

done_testing;
