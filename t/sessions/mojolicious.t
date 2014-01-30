#t/sessions/mojolicious.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Time::Piece;

plan skip_all => "Skipping Mojo::Sessions for now";

my $t = Test::Mojo->new('Ado');

#default configuration from etc/ado.conf(Mojolicious::Sessions)
$t->app->config(session => {type => 'mojo', options => {cookie_name => 'ado_session_mojo'}});
my $cookie_name = $t->app->config('session')->{options}{cookie_name};

# Create new SID
$t->get_ok('/добре/ок');
my $sid = $t->tx->res->cookie($cookie_name)->value;
ok $sid, 'new sid $sid ok';


$t->get_ok("/");
is $sid, $t->tx->res->cookie($cookie_name)->value, 'Cookie $sid ok';

#default_expiration
$t->get_ok("/");
my $default_expiration = $t->app->sessions->default_expiration;
my $expires            = $t->tx->res->cookie($cookie_name)->expires;
my $equal = Time::Piece->strptime($expires)->epoch - gmtime(time + $default_expiration)->epoch;

#may differ with one second
ok($equal == 0 || $equal == -1, '$default_expiration is ok');

#session expired
my $old_session_id = $t->tx->res->cookie($cookie_name)->value;
$t->app->sessions->default_expiration(-3);
$t->get_ok('/добре/ок', 'expired session');
$expires = $t->tx->res->cookie($cookie_name)->expires;
ok(Time::Piece->strptime($expires)->epoch < gmtime(time)->epoch, '$expires is ok');
$t->get_ok("/добре/ок");
my $new_session_id = $t->tx->res->cookie($cookie_name)->value;
isnt($old_session_id, $new_session_id, 'new id is different');

done_testing();

