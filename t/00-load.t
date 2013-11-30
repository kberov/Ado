##!perl -T
use 5.016003;
use strict;
use warnings FATAL => 'all';
use Test::More;

#TODO: Think about abstracting $ENV{XXX} usage via $app->env
# so we can run under -T switch. Disable -T switch because of Mojo till then.
#$ENV{MOJO_BASE_DEBUG}=0;


BEGIN {
    use_ok('Ado')                   || print "Ado failed to load!\n";
    use_ok('Ado::Build')            || print "Ado::Build failed to load!\n";
    use_ok('Ado::Control')          || print "Ado::Control failed to load!\n";
    use_ok('Ado::Control::Default') || print "Ado::Control::Default failed to load!\n";
    use_ok('Ado::Control::Ado')     || print "Ado::Control::Ado failed to load!\n";
    use_ok('Ado::Control::Ado::Default')
      || print "Ado::Control::Ado::Default failed to load!\n";
    use_ok('Ado::Command') || print "Ado::Command failed to load!\n";
}
for ('process_etc_files', 'process_public_files') {
    can_ok('Ado::Build', $_);
}
diag("Testing loading of Ado $Ado::VERSION, Perl $], $^X");

done_testing();
