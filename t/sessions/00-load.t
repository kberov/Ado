#t/sessions/00-load.t
use Mojo::Base -strict;
use Test::More;

use_ok 'Ado::Sessions';
use_ok 'Mojolicious::Sessions';
my $config = {session => {type => 'mojo', options => {}}};
isa_ok my $m = Ado::Sessions::get_instance($config), 'Mojolicious::Sessions';
$config->{session} = {type => 'file', options => {}};
isa_ok my $f = Ado::Sessions::get_instance($config), 'Ado::Sessions::File';
$config->{session} = {type => 'database', options => {}};
isa_ok my $d = Ado::Sessions::get_instance($config), 'Ado::Sessions::Database';

foreach my $method (qw(load store)) {
    foreach my $instance ($f, $d, $m) {
        can_ok $instance, $method;
    }
}

foreach my $method (qw(generate_id)) {
    foreach my $instance ($f, $d) {
        my $sid = $instance->$method;
        ok $sid, "$method $sid ok";
    }
}

done_testing();

