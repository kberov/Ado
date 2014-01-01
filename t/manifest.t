#manifest.t
use 5.014000;
use strict;
use warnings FATAL => 'all';
use Test::More;

unless ($ENV{TEST_AUTHOR}) {
    plan(skip_all => 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.');
}

my $min_tcm = 0.9;
eval "use Test::CheckManifest $min_tcm";
plan skip_all => "Test::CheckManifest $min_tcm required" if $@;

ok_manifest();
done_testing();

