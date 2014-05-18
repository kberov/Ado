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

#from host

SKIP: {
    my $message =
        'Add the following record to your /etc/hosts:'
      . $/
      . '  127.0.0.1 localhost en.localhost bg.localhost'
      . $/
      . '  export TEST_LANGUAGE_FROM_HOST=1'
      . $/
      . ' then rer-un this test to test detection and language switching from host.';
    $ENV{TEST_LANGUAGE_FROM_HOST} or skip $message, 4;
    my $test_url = $t->ua->server->url->to_abs;
    $test_url =~ s/localhost/en.localhost/;
    $t->get_ok("${test_url}test/language_menu")->element_exists('a.active img[alt="en"]');
    $test_url =~ s/en\.localhost/bg.localhost/;
    $t->get_ok("${test_url}test/language_menu")->element_exists('a.active img[alt="bg"]');

}
done_testing;
