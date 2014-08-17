#t/command/adoplugin-01.t
use Mojo::Base -strict;
use Test::More;
use File::Spec::Functions qw(catdir catfile catpath);
use File::Temp qw(tempdir);
use Cwd;

use Mojo::Util qw(decamelize slurp);
use Test::Mojo;

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
my $t   = Test::Mojo->new('Ado');
my $ado = $t->app;

isa_ok(my $c = $command->new(app => $ado), $command);

#create the table
for my $sql (@$create_table) {
    $c->app->dbix->dbh->do($sql);
}
$c->app->dbix->query(
    'INSERT INTO testatii(title,body,user_id,group_id)' . 'VALUES(?,?,?,?)',
    'Hello', 'more text in the body',
    2, 2
);
$c->app->dbix->query(
    'INSERT INTO testatii(title,body,user_id,group_id)' . 'VALUES(?,?,?,?)',
    'Hello2', 'more text in the body2',
    2, 2
);
isa_ok(
    $c->run(
        -n   => $name,
        -c   => 1,
        -t   => 'testatii',
        -T   => "$tempdir/site_templates",
        '-H' => "$tempdir/Ado-Plugin-$name"
    ),
    $command
);
my $crud_class = 'Ado::Command::generate::crud';
ok(ref($c->crud) eq $crud_class,     '$c->crud ISA ' . $crud_class);
ok(ref($c->crud->routes) eq 'ARRAY', '$c->crud->routes ISA ARRAY');

#test generated plugin
unshift @INC, catdir($tempdir, "Ado-Plugin-$name", 'lib');
unshift @{$c->app->renderer->paths}, catdir($tempdir, "Ado-Plugin-$name", 'site_templates');
use_ok($class);
isa_ok(my $plugin = $class->new->register($t->app, {'аз' => 'ти'}), 'Ado::Plugin', $name);

is( $plugin->home_dir,
    catdir($tempdir, "Ado-Plugin-$name"),
    '$plugin->home_dir is ' . catdir($tempdir, "Ado-Plugin-$name")
);
is( $plugin->config_dir,
    catdir($tempdir, "Ado-Plugin-$name", 'etc', 'plugins'),
    'right config directory'
);

# Remove generic routes (for this test only) so newly generated routes can match.
# In a normal application startup generic routes will always match last.
# It is expected all plugins to load their routes by the time the generic routes load.
# This means it is ok to keep them in ado.conf
#http://localhost:3000/perldoc/Mojolicious/Guides/Routing#Rearranging-routes
$ado->routes->find('controller')->remove();
$ado->routes->find('controlleraction')->remove();
$ado->routes->find('controlleractionid')->remove();

# $ado->start("routes");
# Test generated routes
$t->get_ok('/testatii.json')->status_is(200);
$t->get_ok('/testatii/list?format=html')->status_is(200)
  ->content_like(qr|table.+id</th>.+permissions</th.+Hello</td.+Hello2|smx);

# needs login
$t->post_ok(
    '/testatii/create.html' => form => {
        title => 'Hello3',
        body =>
          'Ала, бала, ница турска паница, Хей гиди Ванчо, наш капитанчо...'
    }
  )->status_is(302)    #requires authentication
  ->header_is('Location' => '/login', 'redirected to /login');
my $login_url = $t->tx->res->headers->header('Location');

# Login after following the Location header (redirect)
$t->get_ok($login_url);

#get the csrf fields
my $form       = $t->tx->res->dom->at('#login_form');
my $csrf_token = $form->at('[name="csrf_token"]')->{value};
my $form_hash  = {
    _method        => 'login/ado',
    login_name     => 'test1',
    login_password => '',
    csrf_token     => $csrf_token,
    digest         => Mojo::Util::sha1_hex($csrf_token . Mojo::Util::sha1_hex('test1test1')),
};
$t->post_ok($login_url => {} => form => $form_hash)->status_is(302)
  ->header_is('Location' => '/testatii/create', 'redirected back to /testatii/create');
my $create_url = $t->tx->res->headers->header('Location');

#now we can create a new resouce after authenticating
$t->post_ok(
    $create_url => {Accept => 'text/html'} => form => {
        title => 'Hello3',
        body =>
          'Ала, бала, ница турска паница, Хей гиди Ванчо, наш капитанчо...'
    }
);
$t->get_ok('/testatii/read/3.html')->status_is(200)
  ->content_like(qr|Hello3|smx, 'reading created content - ok');

=pod
=cut

chdir $dir;
done_testing();


