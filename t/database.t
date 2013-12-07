#database.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
sub encode { Mojo::Util::encode $^O=~ /win/i ? 'cp866' : 'UTF-8', $_[0] }
my $t = Test::Mojo->new('Ado');
$t->get_ok('/ado-users/list.html')->status_is(204, 'Status 204 for any content type');
$t->get_ok('/ado-users/list.json')->status_is(200);


done_testing();

