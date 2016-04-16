#!perl
use 5.014000;
use strict;
use warnings FATAL => 'all';
use Test::More;

$SIG{__WARN__} = sub {
    return if $_[0] =~ m|Wide\scharacter\sin\sprint|x;
    warn @_;
};

# Ensure use Test::Pod::Spelling is installed
eval "use Lingua::Ispell";
plan skip_all => "Lingua::Ispell and ispell binary is required for testing POD spelling." if $@;
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
      Krasimir Berov Красимир Беров berov Joachim Astel Renee Baecker kumcho
      vulcho com Вълчо Неделчев Nedelchev Valcho http html org metacpan url
      urls de ingroup absfile Mojolicious Mojo app apps Foo SQLite ActivePerl
      URI OM ORM CPAN ENV CORS REST JSON ERP TODO API STDOUT PLUGIN CMS CMF
      SQL CRM WMD JS UI MVC FCGI CGI ISA JavaScript MYDLjE precompiled perldoc
      RESTful tstamp linkedin wikipedia accessor accessors seq distro bashrc
      perltidy perltidyrc cpan cpanm perl perlbrew auth eg authbar ep wiki
      conf plugin plugins yourpluginroute htaccess suexec env ServerName ln
      ServerAlias ServerAdmin DocumentRoot UserAgent initialisation camelized
      blog uninstall initialise args init bgln dstdir dstfile OAuth2 OAuth ext
      )
);
all_pod_files_spelling_ok();
done_testing();
