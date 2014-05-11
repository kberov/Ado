#t/plugin/i18n-02.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
my $t = Test::Mojo->new('Ado');

#$config->{language_from_cookie}
$t->get_ok('/', 
  {Cookie => Mojo::Cookie::Request->new(name => language => value => 'bg')})
  ->status_is(200)->text_is(
    '#login_form label[for="login_name"]',
    'Потребител',
    '/ Cookie: language=bg content'
  );
$t->get_ok('/test', 
  {Cookie => Mojo::Cookie::Request->new(name => language => value => 'bg')})
  ->content_is('Здрасти, Guest!', '/:controller Cookie: language=bg content');

done_testing;
