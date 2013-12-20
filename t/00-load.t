##!perl -T
use 5.014000;
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

for (
    qw(_empty_log_files process_etc_files _set_env
    process_public_files process_log_files process_templates_files
    ACTION_build ACTION_dist ACTION_install)
  )
{
    can_ok('Ado::Build', $_);
}
for (
    qw(process_etc_files process_public_files process_templates_files
    ACTION_build ACTION_dist ACTION_install)
  )
{
    can_ok('Ado::BuildPlugin', $_);
}
diag("Testing loading of Ado $Ado::VERSION, Perl $], $^X");

done_testing();
