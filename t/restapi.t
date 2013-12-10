#restapi.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
sub encode { Mojo::Util::encode $^O=~ /win/i ? 'cp866' : 'UTF-8', $_[0] }
my $t = Test::Mojo->new('Ado');
$t->get_ok('/ado-users/list.html')
  ->status_is(415, '415 - Unsupported Media Type for any other format');
$t->get_ok('/ado-users/list.json')->status_is(200);


done_testing();

