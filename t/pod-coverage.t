#pod-coverage.t
use 5.014000;
use strict;
use warnings FATAL => 'all';
use Test::More;

if (not $ENV{TEST_AUTHOR}) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan(skip_all => $msg);
}

# Ensure a recent version of Test::Pod::Coverage
my $min_tpc = 1.08;
eval "use Test::Pod::Coverage $min_tpc";
plan skip_all => "Test::Pod::Coverage $min_tpc required for testing POD coverage"
  if $@;

# Test::Pod::Coverage doesn't require a minimum Pod::Coverage version,
# but older versions don't recognize some common documentation styles
my $min_pc = 0.18;
eval "use Pod::Coverage $min_pc";
plan skip_all => "Pod::Coverage $min_pc required for testing POD coverage"
  if $@;
my $trustme = {
    trustme => [
        qr/^(
  ALIASES|CHECKS|COLUMNS|
  PRIMARY_KEY|TABLE|is_base_class|dbix
)$/x
    ]
};
all_pod_coverage_ok($trustme);


done_testing();

