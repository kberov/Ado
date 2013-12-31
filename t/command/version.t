use 5.014000;
use strict;
use warnings;
use Test::More;
use Test::Output;

use_ok('Ado');
my $ACV = 'Ado::Command::version';
use_ok('Ado::Command::version');
isa_ok($ACV->new(), 'Ado::Command');

stdout_like(
    sub { $ACV->new->run },
    qr/$Ado::VERSION.+Mojolicious/msx,
    'current release output ok'
);
$Ado::VERSION = '24.00';
stdout_like(
    sub { $ACV->new->run },
    qr/$Ado::VERSION.+development\sreleas.+Mojolicious/msx,
    'develelopment release output ok'
);
$Ado::VERSION = '0.22';
stdout_like(
    sub { $ACV->new->run },
    qr/$Ado::VERSION.+update\syour\sAdo.+Mojolicious/msx,
    'old release output ok'
);

done_testing();
