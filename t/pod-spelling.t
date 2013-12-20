#!perl
use 5.014000;
use strict;
use warnings FATAL => 'all';
use Test::More;

# Ensure use Test::Pod::Spelling is installed
eval "use Test::Pod::Spelling";
plan skip_all => "Test::Pod::Spelling is required for testing POD spelling." if $@;
if (not $ENV{TEST_AUTHOR}) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan(skip_all => $msg);
}

#TODO: Make Lingua::Ispell aware of UTF8
#or find another way to shut up "Wide character in print" warnings
add_stopwords(
    qw(
      Krasimir Berov Красимир Беров berov URI http html org
      Mojolicious Mojo app apps Foo CPAN ENV SQLite ActivePerl
      OM ORM precompiled perldoc API RESTful JSON tstamp ERP TODO
      accessor accessors seq distro bashrc
      )
);
all_pod_files_spelling_ok();
done_testing();
