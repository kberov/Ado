package Ado::BuildPlugin;
use strict;
use warnings FATAL => 'all';
use File::Spec::Functions qw(catdir catfile catpath);
use File::Path qw(make_path);
use File::Copy qw(copy);
use parent 'Module::Build';
use Ado::Build
  qw(create_build_script process_etc_files process_public_files process_templates_files);


1;


=pod

=encoding utf8

=head1 NAME

Ado::BuildPlugin - Custom routines for Ado::Plugin::* installation 

=head1 SYNOPSIS

    use lib("$ENV{ADO_HOME}/lib");
    use Ado::BuildPlugin;
    my $builder = Ado::BuildPlugin->new(..);
    $builder->create_build_script();

=head1 DESCRIPTION

This is a subclass of L<Module::Build>. 
We use L<Module::Build::API> to add custom functionality 
so we can install Ado  and it plugins in a location chosen by the user.
To use this module for installing your plugins
$ENV{ADO_HOME} must be available and Ado installed there.

This module and L<Ado::Build> exist just because of the aditional install paths
that we use beside c<lib> and <bin>. These modules also can serve as examples 
for your own builders if you have some custom things to do during 
build, test, install and even if you need to add a new C<ACTION_*> to your setup.


=head1 METHODS

Ado::BuildPlugin inherits all methods from L<Module::Build> and implements 
the following ones.

=head2 create_build_script




=cut
