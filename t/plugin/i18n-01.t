#t/plugin/i18n-01.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
my $t = Test::Mojo->new('Ado');

#$config->{language_from_route}
$t->get_ok('/bg')->status_is(200)
  ->text_is('#login_form label[for="login_name"]', 'Потребител', '/:language content');
$t->get_ok('/bg/test')->content_is('Здрасти, Guest!', '/:language/:controller content');
$t->get_ok('/de/test/l10n')->content_is('Hallo Guest,', '/:language/:controller/:action content');
$t->get_ok('/en/test/l10n')->content_is('Hello Guest,', '/:language/:controller/:action content');
$t->get_ok('/en/test/bgl10n')
  ->content_is('Здрасти, Guest!', 'language explicitly set in action');
$t->get_ok('/is')->status_is(404, 'unknown /:language not found');
$t->get_ok('/fr/test')->status_is(404, 'unknown /:language/:controller not found');
$t->get_ok('/is/test/l10n')->status_is(404, 'unknown /:language/:controller:action not found');

#$config->{language_from_host} TODO

#$config->{language_from_param}
$t->get_ok('/?language=bg')->status_is(200)->text_is('#login_form label[for="login_name"]',
    'Потребител', '/?language=bg content');
$t->get_ok('/test?language=bg')
  ->content_is('Здрасти, Guest!', '/:controller?language=bg content');
$t->get_ok('/test/l10n?language=de')
  ->content_is('Hallo Guest,', '/:controller/:action?language=de content');
$t->get_ok('/test/l10n?language=en')
  ->content_is('Hello Guest,', '/:controller/:action?language=en content');
$t->get_ok('/test/bgl10n?language=en')
  ->content_is('Здрасти, Guest!', 'language explicitly set in action');
$t->get_ok('/?language=is')->status_is(200)
  ->text_is('#login_form label[for="login_name"]', 'User', '/?language=is - fallback content');
$t->get_ok('/test?language=fr')->status_is(200)
  ->content_is('Hello Guest,', 'unknown /test?language=fr fallback');
$t->get_ok('/test/l10n?language=it')->status_is(200)
  ->content_is('Hello Guest,', 'unknown /test/l10n?language=it fallback');


done_testing;
