#t/command/adoplugin.t
use Mojo::Base -strict;
use Test::More;
use File::Spec::Functions qw(catdir catfile catpath);
use File::Temp qw(tempdir);
use Cwd;

use Mojo::Util qw(decamelize slurp);
use Test::Mojo;
my $dir = getcwd;

my $tempdir = tempdir( CLEANUP => 1 );
my $create_table = [
    'DROP TABLE IF EXISTS testatii',
    <<TAB,
CREATE TABLE IF NOT EXISTS testatii (
  id INTEGER PRIMARY KEY  NOT NULL, 
  title VARCHAR NOT NULL  UNIQUE , 
  body TEXT, 
  published BOOL DEFAULT '0', 
  deleted BOOL NOT NULL DEFAULT '0', 
  user_id INTEGER REFERENCES users(id), 
  group_id INTEGER REFERENCES groups(id), 
  permissions VARCHAR(10) NOT NULL DEFAULT '-rwxr-xr-x' 
)
TAB
    'CREATE INDEX testatii_published ON testatii(published)',
    'CREATE INDEX testatii_deleted ON testatii(deleted)',
];

TODO: {
    my $command = 'Ado::Command::generate::crud';
    use_ok($command);

    # check defaults
    isa_ok(my $c = $command->new->initialise(-t => 'testatii'), $command);
    my $app = $c->app;
    is_deeply(
        $c->args,
        {   controller_namespace => $app->routes->namespaces->[0],
            dsn                  => undef,
            lib_root             => 'lib',
            model_namespace      => 'Ado::Model',
            no_dsc_code          => undef,
            password             => undef,
            overwrite            => undef,
            templates_root       => $app->home->rel_dir('site_templates'),
            tables               => ['testatii'],
            user                 => undef,
        },
        'args are ok'
    );

    #create the table
    for my $sql (@$create_table) {
        $app->dbix->dbh->do($sql);
    }
    $app->dbix->query(
        'INSERT INTO testatii(title,body,user_id,group_id)' . 'VALUES(?,?,?,?)',
        'Hello', 'more text in the body',
        2, 2
    );
    $app->dbix->query(
        'INSERT INTO testatii(title,body,user_id,group_id)' . 'VALUES(?,?,?,?)',
        'Hello2', 'more text in the body2',
        2, 2
    );

    chdir $tempdir;
    ok($c->run);

    unshift @INC, catdir($tempdir, $c->args->{lib_root});
    delete ${Ado::}{dbix};    #shut up redefine

    #Run tests on the generated code?!?!
    my $t   = Test::Mojo->new('Ado');
    my $ado = $t->app;
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
      ->content_like(qr|Hello3|smx, 'readinkg content - ok');

    #drop the table
    $app->dbix->dbh->do($create_table->[0]);
}


chdir $dir;

done_testing();
