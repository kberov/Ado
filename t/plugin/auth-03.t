#t/plugin/auth-03.t
use Mojo::Base -strict;
use Test::More;
use Mojo::UserAgent;
use Ado;

#start the server
my $LISTEN = 'http://localhost:3000';
my $ado    = Ado->new;
$ado->startup;
my $ua = Mojo::UserAgent->new;
$ua->max_redirects(5);
note('Testing authentication via Google');
if (!List::Util::first { $_ eq 'google' } @{$ado->config('auth_methods')}) {
    plan(skip_all => <<"MSG");
  Missing configuration for these tests. Skipping!
  Look at the source of this file for more information.
MSG
}

# To run these tests:
#   1. Install Mojolicious::Plugin::Oauth2.
#   2. Setup your application using Google Developers Console:
#     https://console.developers.google.com/project/i-caneu-on-ado/apiui/credential
#     Add the following REDIRECT URI:  http://localhost:3000/login/google
#   3. Create ${\$ado->home}/etc/plugins/auth.development.conf
#   4. Add "google" to the list "auth_methods".
#   5. Add configuration for "google" to "providers"
#   6. Use a Google account owned by you for testing
#   7. Run your application: morbo -l "http://*:3000" ./bin/ado
#   8. Run this test: prove -lv t/plugin/auth-03.t
unless ($ua->get($LISTEN)->res->body) {
    plan(skip_all => "First run your application: morbo -l \"http://*:3000\" ./bin/ado"
          . "\n Then run this test in another terminal.");
}

ok($ua && $ado, 'all is set');
ok(my $res = $ua->get($LISTEN . '/authorize/google')->res, '/authorize/google');
is($res->headers->server, 'GSE', 'redirected to GSE');

# No idea how to test the whole flow. Any idea is highly appreciated.
# May be use http://phantomjs.org/

done_testing;
