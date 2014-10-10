#t/plugin/i18n-02.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use List::Util qw(first);
my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

#warn $app->dumper(\%ENV);

#$config->{language_from_cookie}
$t->get_ok('/', {Cookie => Mojo::Cookie::Request->new(name => language => value => 'bg')})
  ->status_is(200)->text_is(
    '#login_form label[for="login_name"]',
    'Потребител',
    '/ Cookie: language=bg content'
  );

$t->get_ok('/test', {Cookie => Mojo::Cookie::Request->new(name => language => value => 'bg')})
  ->content_is('Здрасти, Guest!', '/:controller Cookie: language=bg content');
my $jar = $t->ua->cookie_jar;
my $cookie = first { $_->name eq 'language' } $jar->all;
$cookie->value('en');
$t->get_ok('/test/l10n')
  ->content_is('Hello Guest,', '/:controller/:action Cookie: language=en content');

#$cookie = first {$_->name eq 'language'} $jar->all;
#$cookie->value('bg');
$t->get_ok('/test/bgl10n')
  ->content_is('Здрасти, Guest!', 'language explicitly set in action');

$cookie = first { $_->name eq 'language' } $jar->all;
$cookie->value('de');
$t->get_ok('/')->status_is(200)
  ->text_is('#login_form label[for="login_name"]', 'User', '/:language - fallback content');


$t = Test::Mojo->new($app);

#$config->{language_from_headers}
$t->get_ok('/test/l10n', {'Accept-Language' => 'bg'})
  ->content_is('Здрасти, Guest!', '/:controller Accept-Language: bg content');

$t->get_ok('/test/l10n', {'Accept-Language' => 'en,fr;q=0.8,en-us;q=0.5,en;q=0.3'})
  ->content_is('Hello Guest,', '/:controller/:action Accept-Language: en content');

=pod
=cut

done_testing;
