#t/sessions/database.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Time::Piece;

my $t = Test::Mojo->new('Ado');

#switch to Ado::Sessions::Database
$t->app->config(session => {type => 'database', options => {cookie_name => 'ado_session_id',}});
my $cookie_name = $t->app->sessions->cookie_name;

is($cookie_name, 'ado_session_id', '$cookie_name is ado_session_id');

# Create new SID
$t->get_ok('/добре/ок', 'created new session in template ok');
my $sid = $t->tx->res->cookie($cookie_name)->value;
ok $sid, "new sid $sid ok";

$t->get_ok("/");
is $sid, $t->tx->res->cookie($cookie_name)->value, 'Cookie $sid ok';

#default_expiration
$t->get_ok("/");
my $default_expiration = $t->app->sessions->default_expiration;
my $expires            = $t->tx->res->cookie($cookie_name)->expires;

#may differ with one second
ok(Time::Piece->strptime($expires)->epoch <= gmtime(time + $default_expiration)->epoch,
    '$default_expiration is ok');

#session expired
my $old_session_id = $t->tx->res->cookie($cookie_name)->value;
$t->app->sessions->default_expiration(-3);
$t->get_ok('/добре/ок', 'expired session');
$expires = $t->tx->res->cookie($cookie_name)->expires;
ok(Time::Piece->strptime($expires)->epoch <= gmtime(time)->epoch, '$expires is ok');
$t->get_ok("/добре/ок");
my $new_session_id = $t->tx->res->cookie($cookie_name)->value;
isnt($old_session_id, $new_session_id, 'new id is different');

$t->app->dbix->dbh->do('DELETE FROM sessions');
$t->app->dbix->dbh->do('VACUUM');

done_testing();

