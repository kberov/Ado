#t/plugin/i18n-03.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
my $t = Test::Mojo->new('Ado');

#partials/language_menu
#from route
$t->get_ok('/bg/test/language_menu?from=route')
  ->element_exists('#language_menu a[href="/bg/test/language_menu"]')
  ->element_exists('#language_menu a[href="/en/test/language_menu"]');

#from host
$t->get_ok('/test/language_menu?from=host')->content_like(qr/href="\/\/bg\./)
  ->content_like(qr/href="\/\/en\./);

#from param
$t->get_ok('/test/language_menu?from=param')->content_like(qr/href=".+language=bg"/)
  ->content_like(qr/href=".+language=en"/);

#from cookie
$t->get_ok('/test/language_menu?from=cookie')->content_like(qr/href="\/test\/language_menu"/)
  ->element_exists('#language_menu a.en')->element_exists('#language_menu a.bg');

done_testing;
