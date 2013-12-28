#!perl
use 5.014000;
use strict;
use warnings FATAL => 'all';
use Test::More;
$SIG{__WARN__} = sub {
    return if $_[0] =~ m|Wide\scharacter\sin\sprint|x;
};

# Ensure use Test::Pod::Spelling is installed
eval "use Test::Pod::Spelling";
plan skip_all => "Test::Pod::Spelling is required for testing POD spelling." if $@;
if (!$ENV{TEST_AUTHOR}) {
    my $msg = 'Author test.  Set $ENV{TEST_AUTHOR} to a true value to run.';
    plan(skip_all => $msg);
}

#TODO: Make Lingua::Ispell aware of UTF8
#or find another way to shut up "Wide character in print" warnings
add_stopwords(
    qw(
      Krasimir Berov Красимир Беров berov http html org
      Mojolicious Mojo app apps Foo SQLite ActivePerl
      URI OM ORM CPAN ENV CORS REST JSON ERP TODO API STDOUT
      precompiled perldoc RESTful tstamp
      accessor accessors seq distro bashrc perltidy perltidyrc
      cpan cpanm perl
      )
);
all_pod_files_spelling_ok();
done_testing();
