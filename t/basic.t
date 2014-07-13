use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
sub encode { Mojo::Util::encode $^O=~ /win/i ? 'cp866' : 'UTF-8', $_[0] }
my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

# Ado::define_mime_types()
is($app->types->type('xht'), 'application/xhtml+xml', 'define_mime_types (ok)');

# cyrillic
$t->get_ok('/добре/ок')->status_is(200)
  ->content_like(qr/Добре/i,     encode 'Content contains "Добре".')
  ->content_like(qr/ти си №1/i, encode 'Content contains "ти си №1".');

# qrs
$t->get_ok('/добре/ок/нещо')->status_is(200)
  ->content_like(qr/нещо/i, encode 'Content contains "нещо".');

# default perldoc page
$t->get_ok('/perldoc')->status_is(200)
  ->content_like(qr/Ado::Manual - Getting/i, encode '"/perldoc" Content contains "Ado::Manual".');

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

# default ado page
$t->get_ok('/ado')->status_is(200)->content_like(qr/Controller: ado-default; Action: index/);

# default ado page
$t->get_ok('/ado-default')->status_is(200)
  ->content_like(qr/Controller: ado-default; Action: index/);

# default ado page
$t->get_ok('/ado-default/index')->status_is(200)
  ->content_like(qr/Controller: ado-default; Action: index/);
$t->get_ok('/ado-default/form')->status_is(200)
  ->content_like(qr/Controller: ado-default; Action: form/);

done_testing();

