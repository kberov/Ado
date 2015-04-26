use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

sub encode { Mojo::Util::encode $^O=~ /win/i ? 'cp866' : 'UTF-8', $_[0] }
my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

#with default configuration
ok($app->ado_home, 'ado_home is set');
is($app->ado_home, $app->home, 'home is equal to ado_home');
like($app->CODENAME, qr/CAPITAL\sLETTER/x);

# Ado::define_mime_types()
is($app->types->type('xht'), 'application/xhtml+xml', 'define_mime_types (ok)');

# default perldoc page
$t->get_ok('/perldoc')->status_is(200)
  ->content_like(qr/Ado::Manual/i, encode '"/perldoc" Content contains "Ado::Manual".');

# default page
$t->get_ok('/')->status_is(200)
  ->content_like(qr/Produced by/i, 'Content contains "Produced by".')
  ->content_like(qr/Ado::Control::Default::index/);

# default page
$t->get_ok('/default')->status_is(200)->content_like(qr/Controller: default; Action: index/);

# default page
$t->get_ok('/default/index')->status_is(200)
  ->content_like(qr/Controller: default; Action: index/);
$t->get_ok('/default/form')->status_is(200)->content_like(qr/Controller: default; Action: form/);

#with empty configuratuion
$ENV{MOJO_CONFIG} = $app->home->rel_file('t/ado/etc/empty.conf');
$t                = Test::Mojo->new('Ado');
$app              = $t->app;
isa_ok($app, 'Ado');

#with plugin without configuration
$ENV{MOJO_CONFIG} = $app->home->rel_file('t/ado/etc/bare.conf');
$t                = Test::Mojo->new('Ado');
$app              = $t->app;
isa_ok($app, 'Ado');


done_testing();

