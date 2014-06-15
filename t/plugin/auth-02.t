#t/plugin/auth-02.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Find;

my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.

my $csrf_token =
  $t->get_ok('/login')->tx->res->dom->at('#login_form [name="csrf_token"]')->{value};
$t->post_ok(
    '/login' => {} => form => {
        _method    => 'login/ado',
        csrf_token => $csrf_token,
    }
)->status_is(401 => 'user submitted empty form 401 ok');
my $login_url =
  $t->get_ok('/test/authenticateduser')->status_is(302)->header_like('Location' => qr|/login$|)
  ->tx->res->headers->header('Location');
$t->get_ok('/login/ado');

#try again with the right password this time
my $form           = $t->tx->res->dom->at('#login_form');
my $new_csrf_token = $form->at('[name="csrf_token"]')->{value};
ok($new_csrf_token ne $csrf_token, '$new_csrf_token is different');
$t->post_ok(
    $login_url => {},
    form       => {
        _method        => 'login/ado',
        login_name     => 'test1',
        login_password => '',
        csrf_token     => $new_csrf_token,
        digest => Mojo::Util::sha1_hex($new_csrf_token . Mojo::Util::sha1_hex('test1' . 'test1')),
      }

      #redirect back to the $c->session('over_route')
)->status_is(302)->header_is('Location' => '/test/authenticateduser');


# after authentication
$t->get_ok('/test/authenticateduser')->status_is(200)
  ->content_is('hello authenticated Test 1', 'hello test1 ok');

#user is Test 1
$t->get_ok('/')->status_is(200)->text_is('article.ui.main.container h1' => 'Hello Test 1,')
  ->element_exists('#adobar #authbar a.item .sign.out.icon', 'Sign Out link is present!');

#logout
$t->get_ok('/logout')->status_is(302)->header_is('Location' => '/');
$t->get_ok('/')->status_is(200)->text_is('article.ui.main.container h1' => 'Hello Guest,');


done_testing();
