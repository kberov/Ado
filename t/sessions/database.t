#t/sessions/database.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Ado');

#switch to Ado::Sessions::Database
$t->app->config(
    session => {
        type    => 'database',
        options => {cookie_name => 'ado_session_id'}
    }
);
my $cookie_name = $t->app->config('session')->{options}{cookie_name};

is($cookie_name, 'ado_session_id', '$cookie_name is ado_session_id');

# Create new SID
$t->get_ok('/добре/ок');
my $sid = $t->tx->res->cookie($cookie_name)->value;
ok $sid, "new sid $sid ok";
$t->get_ok("/?$cookie_name=$sid");
is $sid, $t->tx->res->cookie($cookie_name)->value, 'Param $sid ok';

$t->get_ok("/");
is $sid, $t->tx->res->cookie($cookie_name)->value, 'Cookie $sid ok';


done_testing();

