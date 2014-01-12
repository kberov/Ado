#ado-sessions.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

use_ok 'Ado::Sessions';
use_ok 'Mojolicious::Sessions';

isa_ok my $f = Ado::Sessions::get_instance('file'), 'Ado::Sessions::File';
isa_ok my $d = Ado::Sessions::get_instance('db'),   'Ado::Sessions::Database';
isa_ok my $m = Ado::Sessions::get_instance('mojo'), 'Mojolicious::Sessions';

foreach my $method (qw(load store)) {
    foreach my $instance ( $f, $d, $m ) {
        can_ok $instance, $method;
    }
}

foreach my $method (qw(generate_id)) {
    foreach my $instance ( $f, $d ) {
        my $sid = $instance->$method;
        ok $sid, "$method $sid ok";
    }
}

#sub encode { Mojo::Util::encode $^O=~ /win/i ? 'cp866' : 'UTF-8', $_[0] }
my $t = Test::Mojo->new('Ado');

# Create new SID
$t->get_ok('/?adosessionid=123456789');
my $sid = $t->tx->res->cookie('adosessionid')->value;
ok $sid, "new sid $sid ok";

$t->get_ok("/?adosessionid=$sid");
is $sid, $t->tx->res->cookie('adosessionid')->value, "Param $sid ok";

#$t->get_ok("/");
#is $sid, $t->tx->res->cookie('adosessionid')->value, "Cookie $sid ok";

#$t->get_ok("/?adosessionid=wrong");
#isnt $sid, $t->tx->res->cookie('adosessionid')->value, "Param wrong sid ok";

#$t->tx->req->cookie('adosessionid', 'WRONG!');
#$t->get_ok("/");
#isnt $sid, $t->tx->res->cookie('adosessionid')->value, "Bad SID ok";

done_testing();

