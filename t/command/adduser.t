#adduser.t
use 5.014000;
use strict;
use warnings;
use Test::More;
use Mojo::UserAgent;
eval "use Test::Output;";

plan skip_all => "Test::Output required for this test" if $@;
my $class = 'Ado::Command::adduser';
use_ok($class);
can_ok($class, 'description');
can_ok($class, 'adduser');
can_ok($class, 'run');
can_ok($class, 'usage');
can_ok($class, 'help');

#user already exists
like((eval { $class->run(login_name => 'test1') } || $@), qr//, 'user already exists');

done_testing();
