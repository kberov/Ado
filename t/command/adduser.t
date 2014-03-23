#adduser.t
use 5.014000;
use strict;
use warnings;
use Test::More;
use Mojo::UserAgent;
eval "use Test::Output;";

plan skip_all => "Test::Output required for this test" if $@;
use_ok('Ado::Command::adduser');

done_testing();
