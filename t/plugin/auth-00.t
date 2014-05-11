#t/plugin/auth-00.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Find;


my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.
my $class = 'Ado::Plugin::Auth';
use_ok($class);
can_ok($class, 'authenticated');
can_ok($class, 'login');
can_ok($class, 'logout');
can_ok($class, 'register');
can_ok($class, 'config');

done_testing();
