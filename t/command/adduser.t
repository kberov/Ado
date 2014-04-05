#adduser.t
use 5.014000;
use strict;
use warnings;
use Test::More;
use Mojo::UserAgent;
use Ado;

eval "use Test::Output;";
plan skip_all => "Test::Output required for this test" if $@;

#need a running app so db connection is established
#and model classes are loaded
my $app   = Ado->new();
my $class = 'Ado::Command::adduser';
use_ok($class);
can_ok($class, 'description');
can_ok($class, 'adduser');
can_ok($class, 'run');
can_ok($class, 'usage');
can_ok($class, 'help');

#user already exists
stdout_like(
    sub { $app->start('adduser', '--login_name' => 'test1') },
    qr/'test1' is already taken!/,
    'user already exists'
);

#user is already in group
stdout_is(
    sub { $app->start('adduser', '--login_name' => 'test1', '--ingroup' => 'test1') },
    "'test1' is already taken!\nUser 'test1' is already in group 'test1'.$/",
    'user is already in group'
);
my $opt = {'--login_name' => 'test3'};

#insufficient arguments 1
output_like(
    sub { $app->start('adduser', %$opt) },
    qr/Minimal req.+/,
    qr/ERROR adding user\(rolling back\):/sm,
    'insufficient arguments 1'
);

#insufficient arguments 2
$opt->{'--email'} = 'test3@localhost';
output_like(
    sub { $app->start('adduser', %$opt) },
    qr/Minimal req.+/,
    qr/ERROR adding user\(rolling back\):/,
    'insufficient arguments 2'
);

#insufficient arguments 3
$opt->{'--f'} = 'First';
output_like(
    sub { $app->start('adduser', %$opt) },
    qr/Minimal req.+/,
    qr/ERROR adding user\(rolling back\):/,
    'insufficient arguments 3'
);

#insufficient arguments 3
$opt->{'--l'} = 'Last';
stdout_is(
    sub { $app->start('adduser', %$opt) },
    "User 'test3' was created with primary group 'test3'.\n",
    "User 'test3' was created..."
);
$opt->{'--ingroup'} = 'guest';
stdout_is(
    sub { $app->start('adduser', %$opt) },
    "'test3' is already taken!\nUser 'test3' was added to group 'guest'.\n",
    "User 'test3' was created..."
);
my $uid = Ado::Model::Users->by_login_name($opt->{'--login_name'})->id;
$app->dbix->query('DELETE FROM user_group WHERE user_id=?', $uid);
$app->dbix->query('DELETE FROM users WHERE id=?',           $uid);
$app->dbix->query('DELETE FROM groups WHERE name=?',        $opt->{'--login_name'});

done_testing();
