#t/plugin/auth-03.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
my $t   = Test::Mojo->new('Ado');
my $ado = $t->app;

# Notes: To run these tests:
#   1. Install Mojolicious::Plugin::Oauth2.
#   2. Setup your application using Google Developers Console:
#     https://console.developers.google.com/project/i-caneu-on-ado/apiui/credential
#     Add the following REDIRECT URI:  http://localhost:3000/login/google
#   3. Create ${\$ado->home}/etc/plugins/auth.development.conf
#   4. Add "google" to the list "auth_methods".
#   5. Add configuration for "google" to "providers"
#   6. Use a Google account owned by you for testing
#   7. Run this test: prove -lv t/plugin/auth-03.t
my $why = 'Missing configuration for %s tests. Skipping!';

SKIP: {
    skip sprintf($why, 'Google'), 3
      unless (List::Util::first { $_ eq 'google' } @{$ado->config('auth_methods')});

    $t->get_ok('/authorize/google')->status_is(302)
      ->header_like(Location => qr|^https://accou.+?response_type=code|,);
}

# TODO: Fake the communication flow with Google to test the
# functionality under /login/google.
# No idea how to test the whole real flow. Any idea is highly appreciated.
# May be use http://phantomjs.org/
SKIP: {
    skip sprintf($why, 'Facebook'), 3
      unless (List::Util::first { $_ eq 'facebook' } @{$ado->config('auth_methods')});

    $t->get_ok('/authorize/facebook')->status_is(302)
      ->header_like(Location => qr|^https://graph.facebook.com/oauth/authorize\?client_id=|,);
}

done_testing;
