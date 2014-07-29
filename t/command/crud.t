#t/command/adoplugin.t
use Mojo::Base -strict;
use Test::More;
use File::Spec::Functions qw(catdir catfile catpath);
use File::Temp qw(tempdir);
use Cwd;

use Mojo::Util qw(decamelize slurp);
use Test::Mojo;
my $dir = getcwd;

my $tempdir = tempdir(

    #CLEANUP => 1
);
my $create_table = [
    'DROP TABLE IF EXISTS testatii',
    <<TAB,
CREATE TABLE IF NOT EXISTS testatii (
  "id" INTEGER PRIMARY KEY  NOT NULL  check(typeof("id") = 'integer') , 
  "title" VARCHAR NOT NULL  UNIQUE , 
  "body" TEXT check(typeof("body") = 'text') , 
  "published" BOOL, 
  "deleted" BOOL NOT NULL , 
  "user_id" INTEGER REFERENCES users(id) check(typeof("user_id") = 'integer') , 
  "group_id" INTEGER REFERENCES groups(id) check(typeof("group_id") = 'integer') , 
  "permissions" VARCHAR
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
    chdir $tempdir;
    ok($c->run);

    #unshift @INC, catdir($tempdir, $c->args->{lib_root});
    #local $ENV{MOJO_HOME} = $tempdir;

}

chdir $dir;
done_testing();
