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
  ->content_like(qr/updated rows\: 1/, 'do_sql_file app monkey_patch');


done_testing;
