#t/command/adoplugin-01.t
use Mojo::Base -strict;
use Test::More;
use File::Spec::Functions qw(catdir catfile catpath);
use File::Temp qw(tempdir);
use Cwd;

use Mojo::Util qw(decamelize slurp);

#use Test::Mojo;
#my $t   = Test::Mojo->new('Ado');
#my $app = $t->app;

my $command = 'Ado::Command::generate::adoplugin';
require_ok($command);

my $dir = getcwd;
my $tempdir = tempdir(CLEANUP => 1);
chdir $tempdir;
my $name         = 'MyBlog';
my $class        = "Ado::Plugin::$name";
my $decamelized  = decamelize($name);
my $create_table = [
    'DROP TABLE IF EXISTS testatii',
    <<TAB,
CREATE TABLE IF NOT EXISTS testatii (
  id INTEGER PRIMARY KEY, 
  title VARCHAR NOT NULL UNIQUE , 
  body TEXT NOT NULL, 
  published BOOL DEFAULT '0', 
  deleted BOOL NOT NULL DEFAULT '0', 
  user_id INTEGER REFERENCES users(id), 
  group_id INTEGER REFERENCES groups(id), 
  permissions VARCHAR(10) DEFAULT '-rwxr-xr-x' 
)
TAB
    'CREATE INDEX testatii_published ON testatii(published)',
    'CREATE INDEX testatii_deleted ON testatii(deleted)',
];

isa_ok(my $c = $command->new, $command);

#create the table
for my $sql (@$create_table) {
    $c->app->dbix->dbh->do($sql);
}

isa_ok(
    $c->run(
        -n => $name,
        -c => 1,
        -t => 'testatii',
        -T => "$tempdir/site_templates",
    ),
    $command
);
my $crud_class = 'Ado::Command::generate::crud';
ok(ref($c->crud) eq $crud_class,     '$c->crud ISA ' . $crud_class);
ok(ref($c->crud->routes) eq 'ARRAY', '$c->crud->routes ISA ARRAY');

#test generated plugin
unshift @INC, catdir($tempdir, "Ado-Plugin-$name", 'lib');

use_ok($class);
isa_ok(my $plugin = $class->new, $class);
is( $plugin->home_dir,
    catdir($tempdir, "Ado-Plugin-$name"),
    '$plugin->home_dir is ' . catdir($tempdir, "Ado-Plugin-$name")
);
is( $plugin->config_dir,
    catdir($tempdir, "Ado-Plugin-$name", 'etc', 'plugins'),
    'right config directory'
);


chdir $dir;
done_testing();


