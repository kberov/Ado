#ado_helpers.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

like((eval { $app->do_sql_file('') }, $@), qr/Can't open file/, 'app->do_sql_file dies ok');
like(
    (eval { $app->do_sql_file($app->home->rel_file('t/ado/etc/plugins/foo_no_st.sql')) }, $@),
    qr/DBD::SQLite::db do failed: near "updae"/,
    'app->do_sql_file dies on SQL ok'
);
$t->get_ok('/test/ado_helpers')->content_like(qr/\["guest"/i, 'user helper')
  ->content_like(qr/\:"Петър"/,   'to_json helper')
  ->content_like(qr/updated rows\: 1/, 'do_sql_file app monkey_patch')

#head_css and head_javascript
  ->content_like(qr|/\* content for head_css \*/|,                  'content for head_css')
  ->content_like(qr|<link href=".+/reset.min.css"|,                 'reset.min.css')
  ->content_like(qr|<link href=".+/transition.min.css"|,            'transition.min.css')
  ->content_like(qr|<link href=".+/site.min.css|,                   'site.min.css')
  ->content_like(qr|//content for head_javascript|,                 'content for head_javascript')
  ->content_like(qr|<script src=".+transition.min.js"></script>|,   'transition.min.js')
  ->content_like(qr|<script src="mojo/jquery/jquery.js"></script>|, 'jquery.js');

$t->get_ok('/mojo/jquery/jquery.js')->status_is(200);

done_testing;
