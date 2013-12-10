##!perl -T
use 5.014002;
use strict;
use warnings FATAL => 'all';
use Test::More;
use File::Find;

#TODO: Think about abstracting $ENV{XXX} usage via $app->env
# so we can run under -T switch. Disable -T switch because of Mojo till then.
#$ENV{MOJO_BASE_DEBUG}=0;
my @files;
find(
    {   wanted => sub { /\.pm$/ and push @files, $File::Find::name },
        no_chdir => 1
    },
    -e 'blib' ? 'blib' : 'lib',
);

for my $file (@files) {
    my $module = $file;
    $module =~ s,\.pm$,,;
    $module =~ s,.*/?lib/,,;
    $module =~ s,/,::,g;

    use_ok($module) || diag $@;
}

for ('process_etc_files', 'process_public_files') {
    can_ok('Ado::Build', $_);
}
diag("Testing loading of Ado $Ado::VERSION, Perl $], $^X");

done_testing();
