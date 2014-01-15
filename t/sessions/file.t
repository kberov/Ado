#t/sessions/file.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use Time::Piece;

my $t = Test::Mojo->new('Ado');
$t->app->config(session => {type => 'file', options => {cookie_name => 'ado_session_file',}});

my $cookie_name = $t->app->config('session')->{options}{cookie_name};
is($cookie_name, 'ado_session_file', '$cookie_name is ado_session_file');

# Create new SID
$t->get_ok('/добре/ок', 'created new session in template ok');
my $sid = $t->tx->res->cookie($cookie_name)->value;
ok $sid, "new sid $sid ok";

$t->get_ok("/");
is $sid, $t->tx->res->cookie($cookie_name)->value, 'Cookie $sid ok';

my $default_expiration = $t->app->sessions->default_expiration;
my $expires            = $t->tx->res->cookie($cookie_name)->expires;
is( Time::Piece->strptime($expires)->epoch,
    gmtime(time + $default_expiration)->epoch,
    '$default_expiration is ok'
);


done_testing();
