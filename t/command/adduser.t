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
subtest 'Ado::Command::adduser/can_ok' => sub {
    use_ok($class);
    can_ok($class, 'description');
    can_ok($class, 'args');
    can_ok($class, 'init');
    can_ok($class, 'run');
    can_ok($class, 'adduser');
    can_ok($class, 'usage');
    can_ok($class, 'help');
};
my $opt_existing = {};

subtest 'Ado::Command::adduser/output_existing' => sub {

#user already exists
    $opt_existing = {'--login_name' => 'test1'};
    sub add_existing { $app->start('adduser', %$opt_existing) }

    stdout_like(\&add_existing, qr/'test1' is already taken!/, 'user already exists');

#user is already in group
    $opt_existing->{'--ingroup'} = 'test1';
    stdout_is(
        \&add_existing,
        "'test1' is already taken!\nUser 'test1' is already in group 'test1'.$/",
        'user is already in group'
    );
};

my $opt = {};
subtest 'Ado::Command::adduser/output_insufficient_arguments' => sub {

#insufficient arguments 1
    $opt = {'--login_name' => 'test3'};
    sub add { $app->start('adduser', %$opt) }
    output_like(
        \&add,
        qr/Minimal req.+/,
        qr/ERROR adding user\(rolling back\):/sm,
        'insufficient arguments 1'
    );

#insufficient arguments 2
    $opt->{'--email'} = 'test3@localhost';
    output_like(
        \&add,
        qr/Minimal req.+/,
        qr/ERROR adding user\(rolling back\):/,
        'insufficient arguments 2'
    );

#insufficient arguments 3
    $opt->{'--f'} = 'First';
    output_like(
        \&add,
        qr/Minimal req.+/,
        qr/ERROR adding user\(rolling back\):/,
        'insufficient arguments 3'
    );
};
subtest 'Ado::Command::adduser/output_sufficient_arguments' => \&output_sufficient_arguments;

sub output_sufficient_arguments {

#sufficient arguments 1
    $opt->{'--l'} = 'Last';
    stdout_is(
        \&add,
        "User 'test3' was created with primary group 'test3'.\n",
        "User 'test3' was created..."
    );

#sufficient arguments 2
    $opt->{'-g'} = 'guest';
    stdout_is(
        \&add,
        "'test3' is already taken!\nUser 'test3' was added to group 'guest'.\n",
        "User 'test3' was added to group 'guest'..."
    );
};    #end subtest

my $uid = Ado::Model::Users->by_login_name($opt->{'--login_name'})->id;
$app->dbix->query('DELETE FROM user_group WHERE user_id=?', $uid);
$app->dbix->query('DELETE FROM users WHERE id=?',           $uid);
$app->dbix->query('DELETE FROM groups WHERE name=?',        $opt->{'--login_name'});

#=pod

#subtest 'Ado::Command::adduser/ouput_invalid_arguments' =>
my $opt_ = {
    '--login_name' => 'test3' . (1 x 96),
    '--email'      => 'test3atlocalhost',
    '-f'           => ('First' x 50),
    '-l'           => 'Last' x 50,
    '-p'           => 'asdasd',
};
subtest 'Ado::Command::adduser/stderr_invalid_arguments' => \&stderr_invalid_arguments;
sub add_ { $app->start('adduser', %$opt_) }

sub stderr_invalid_arguments {

    stderr_like(\&add_, qr/ERROR adding user.+login_name/sm, 'invalid login_name');
    $opt_->{'--login_name'} = 'test3';
    stderr_like(\&add_, qr/ERROR adding user.+email/sm, 'invalid email');
    $opt->{'--email'} = 'test3@localhost';
    stderr_like(\&add_, qr/ERROR adding user.+first_name/sm, 'invalid first_name');
    stderr_like(\&add_, qr/ERROR adding user.+last_name/sm,  'invalid last_name');

}

#Going deeper
subtest 'Ado::Command::adduser/direct_usage' => \&direct_usage;

sub direct_usage {
    isa_ok(my $command = $class->new(), $class);
    like((eval { $command->init() }, $@), qr/^usage/, 'init croaks "usage..."');
    ok($command->init(%$opt, '--login_password' => '--------'), "\$command->init");
    is($command->args->{login_password}, Mojo::Util::sha1_hex('test3--------'), 'login_password');

    is($command->args->{first_name}, $opt->{'--f'},          'first_name');
    is($command->args->{last_name},  $opt->{'--l'},          'last_name');
    is($command->args->{login_name}, $opt->{'--login_name'}, 'login_name');
    is($command->args->{email},      $opt->{'--email'},      'email');
    is($command->args->{ingroup},    $opt->{'-g'},           'ingroup');
    my $out = <<'OO';
User 'test3' was created with primary group 'test3'.
User 'test3' was added to group 'guest'.
OO

    stdout_is(sub { $command->adduser() }, $out, 'adduser');
    my $user = Ado::Model::Users->by_login_name($opt->{'--login_name'});

    $uid = $user->id;
    is($user->login_password, Mojo::Util::sha1_hex('test3--------'), '$user->login_password');
    is($user->email, $opt->{'--email'}, '$user->email');
}    #end direct_usage
$app->dbix->query('DELETE FROM user_group WHERE user_id=?', $uid);
$app->dbix->query('DELETE FROM users WHERE id=?',           $uid);
$app->dbix->query('DELETE FROM groups WHERE name=?',        $opt->{'--login_name'});
done_testing();
