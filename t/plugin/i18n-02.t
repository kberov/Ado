#t/plugin/i18n-02.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
my $t = Test::Mojo->new('Ado');

#$config->{language_from_cookie}
$t->get_ok('/', {Cookie => Mojo::Cookie::Request->new(name => language => value => 'bg')})
  ->status_is(200)->text_is(
    '#login_form label[for="login_name"]',
    'Потребител',
    '/ Cookie: language=bg content'
  );
$t->get_ok('/test', {Cookie => Mojo::Cookie::Request->new(name => language => value => 'bg')})
  ->content_is('Здрасти, Guest!', '/:controller Cookie: language=bg content');
$t->get_ok('/test/l10n',
    {Cookie => Mojo::Cookie::Request->new(name => language => value => 'en')})
  ->content_is('Hello Guest,', '/:controller/:action Cookie: language=en content');

$t->get_ok('/test/bgl10n',
    {Cookie => Mojo::Cookie::Request->new(name => language => value => 'en')})
  ->content_is('Здрасти, Guest!', 'language explicitly set in action');
$t->get_ok('/', {Cookie => Mojo::Cookie::Request->new(name => language => value => 'de')})
  ->status_is(200)
  ->text_is('#login_form label[for="login_name"]', 'User', '/:language - fallback content');

delete ${Ado::}{dbix};
$t = Test::Mojo->new('Ado');

#$config->{language_from_headers}
$t->get_ok('/test/l10n', {'Accept-Language' => 'bg'})
  ->content_is('Здрасти, Guest!', '/:controller Accept-Language: bg content');

$t->get_ok('/test/l10n', {'Accept-Language' => 'en,fr;q=0.8,en-us;q=0.5,en;q=0.3'})
  ->content_is('Hello Guest,', '/:controller/:action Accept-Language: en content');

done_testing;
