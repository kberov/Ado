#ado_helpers.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

$t->get_ok('/test/ado_helpers')->content_like(qr/\["guest"/i, 'user helper')
  ->content_like(qr/\:"Петър"/, 'to_json helper');

done_testing;
