#t/plugin/auth-02.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Find;

my $t   = Test::Mojo->new('Ado');
my $ado = $t->app;

#Plugins are loaded already.
# Remove generic routes (for this test only) so newly generated routes can match.
# In a normal application startup generic routes will always match last.
# It is expected all plugins to load their routes by the time the generic routes load.
# This means it is ok to keep them in ado.conf
#http://localhost:3000/perldoc/Mojolicious/Guides/Routing#Rearranging-routes
$ado->routes->find('controller')->remove();
$ado->routes->find('controlleraction')->remove();
$ado->routes->find('controlleractionid')->remove();
$ado->routes->get('/test/ingroup')->over(ingroup => 'test1')->to('test#ingroup');

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

#authorization
$t->get_ok('/test/ingroup')->status_is(200)->json_is('/0/login_name' => 'test1');
$t->get_ok('/test/ingroup', form => {limit => 20, offset => 1})->status_is(200)
  ->json_is('/0/login_name' => undef);

#logout
$t->get_ok('/logout')->status_is(302)->header_is('Location' => '/');
$t->get_ok('/')->status_is(200)->text_is('article.ui.main.container h1' => 'Hello Guest,');

#authorization
$t->get_ok('/test/ingroup')->status_is(404)->content_type_is('text/html;charset=UTF-8');


done_testing();
