package Test::AdoPlugin;
use Mojo::Base -strict;
use Exporter qw(import);
use Test::More;
use Test::Mojo;
use Cwd qw(abs_path);
use File::Spec::Functions qw(catdir catfile);
our @EXPORT_OK = qw(abs_path catdir catfile $T);
our $T;
our $OUTPUT_ENCODING = $^O =~ /win/i ? 'cp866' : 'utf8';

#setup the needed environment
#TODO: Think of a better way to set up the test environment than using %ENV
# if possible
sub setup {
    my ($class, $file) = @_;
    $ENV{MOJO_MODE} = 'development';    ## no critic (RequireLocalizedPunctuationVars)
    ($ENV{MOJO_HOME}) = abs_path($file) =~ m|^(.+)/[^/]+$|;
    my @libs = (
        -e catdir($ENV{MOJO_HOME}, '..', 'blib')
        ? catdir($ENV{MOJO_HOME}, '..', 'blib')
        : catdir($ENV{MOJO_HOME}, '..', 'lib')
    );

    for my $d (@libs) {
        unshift @INC, $d if -d $d and not(List::Util::first { $d eq $_ } @INC);
    }
    $ENV{MOJO_CONFIG} =
      catfile($ENV{MOJO_HOME}, 'etc', 'ado.conf');   ##no critic (RequireLocalizedPunctuationVars)
    binmode STDOUT, ":$OUTPUT_ENCODING";
    $T = Test::Mojo->new('Ado');
    return $T;
}

1;

=pod

=encoding utf8

=head1 NAME

Test::AdoPlugin - This module is deprecated

=head1 SYNOPSIS

  #in your plugin basic.t or restapi etc...

=head1 DESCRIPTION

This module is deprecated, Mojo seems to have what we needed so far and
what it missed is now in L<Ado::Plugin> base class.
This modules holds boilerplate code which sets up the environment for your
Ado plugin tests

=head1 METHODS

=head2 setup

Sets up the C<$ENV{MOJO_MODE}>, C<$ENV{MOJO_HOME}>, modifies C<@INC>
and requires the needed modules.

=head1 GLOBAL VARIABLES

=head2 $OUTPUT_ENCODING

Encode STDOUT to avoid "Wide character in print" warning. 
Defaults to cp866 for windows and UTF-8 otherwise.

=head2 $T

The current L<Test::Mojo> instance.

=cut

