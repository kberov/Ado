#t/command/adoplugin.t
use Mojo::Base -strict;
use Test::More;
use File::Spec::Functions qw(catdir catfile);
use File::Temp qw(tempdir);
use Cwd;

use Mojo::Util qw(decamelize slurp);
use Test::Mojo;

my $tempdir = tempdir(CLEANUP => 1);
my $create_table = [
    'DROP TABLE IF EXISTS testatii',
    <<TAB,
CREATE TABLE IF NOT EXISTS testatii (
  id INTEGER PRIMARY KEY,
  title VARCHAR NOT NULL UNIQUE,
  body TEXT NOT NULL,
  published BOOL DEFAULT '0',
  deleted BOOL NOT NULL DEFAULT '0',
  user_id INTEGER REFERENCES users(id),
  group_id INTEGER REFERENCES groups(id),
  permissions VARCHAR(10) DEFAULT '-rwxr-xr-xr'
)
TAB
    'CREATE INDEX testatii_published ON testatii(published)',
    'CREATE INDEX testatii_deleted ON testatii(deleted)',
];
my $t   = Test::Mojo->new('Ado');
my $ado = $t->app;

my $command = 'Ado::Command::generate::crud';
use_ok($command);

# check defaults
isa_ok(
    my $c = $command->new(app => $ado)->initialise(
        '-t' => 'testatii',
        '-H' => $tempdir,
        '-T' => catdir($tempdir, 'site_templates')
    ),
    $command
);
is_deeply(
    $c->args,
    {   controller_namespace => $ado->routes->namespaces->[0],

        #dsn                  => undef,
        lib             => catdir($tempdir, 'lib'),
        model_namespace => 'Ado::Model',

        #no_dsc_code    => undef,
        #password       => undef,
        overwrite      => undef,
        templates_root => catdir($tempdir, 'site_templates'),
        tables         => ['testatii'],
        home_dir       => $tempdir,

        #user           => undef,
    },
    'args are ok'
);
is(ref($c->routes), 'ARRAY', '$c->routes ISA ARRAY');
is_deeply(
    $c->routes->[0],
    {   route => '/testatii',
        via   => ['GET'],
        to    => "testatii#list",
    },
    'first root is OK'
);

#create the table
for my $sql (@$create_table) {
    $ado->dbix->dbh->do($sql);
}
$ado->dbix->query(
    'INSERT INTO testatii(title,body,user_id,group_id)' . 'VALUES(?,?,?,?)',
    'Hello', 'more text in the body',
    2, 2
);
$ado->dbix->query(
    'INSERT INTO testatii(title,body,user_id,group_id)' . 'VALUES(?,?,?,?)',
    'Hello2', 'more text in the body2',
    2, 2
);

ok($c->run);

unshift @INC, $c->args->{lib};

#Run tests on the generated code?!?!
unshift @{$ado->renderer->paths}, catdir($tempdir, 'site_templates');
$t->get_ok('/testatii/list')->status_is(415)
  ->content_like(qr|Unsupported.+Please.+list\.json|x, 'Unsupported Media Type - ok');

$t->get_ok('/testatii/list.json')->status_is(200);
$t->get_ok('/testatii/list.html')->status_is(200)
  ->content_like(qr|table.+id</th>.+permissions</th.+Hello</td.+Hello2|smx);

$t->post_ok(
    '/testatii/create.html' => form => {
        title => 'Hello3',
        body =>
          'Ала, бала, ница турска паница, Хей гиди Ванчо, наш капитанчо...'
    }
);
$t->get_ok('/testatii/read/3.html')->status_is(200)
  ->content_like(qr|Hello3|smx, 'reading content - ok');
$t->put_ok(
    '/testatii/update/3.html' => form => {
        id    => 3,
        title => 'Hello3 Updated',
        body =>
          'Ала, бала, ница турска паница, Хей гиди Ванчо, наш капитанчо...'
    }
);

$t->get_ok('/testatii/read/3.html')->status_is(200)
  ->content_like(qr|Hello3\sUpdated</h1>|smx, 'reading updated content - ok');

=pod

=cut

#drop the table
$ado->dbix->dbh->do($create_table->[0]);


done_testing();
