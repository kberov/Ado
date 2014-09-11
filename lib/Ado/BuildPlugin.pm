package Ado::BuildPlugin;
use 5.014;
use strict;
use warnings FATAL => 'all';
use File::Spec::Functions qw(catdir catfile catpath);
use File::Path qw(make_path);
use File::Copy qw(copy);
use parent 'Module::Build';
use Ado::Build qw(
  process_etc_files process_public_files
  process_templates_files create_build_script
  ACTION_perltidy ACTION_submit PERL_DIRS);


1;


=pod

=encoding utf8

=head1 NAME

Ado::BuildPlugin - Custom routines for Ado::Plugin::* installation 

=head1 SYNOPSIS

    #Ado must be already installed  and 
    #Ado::BuildPlugin should be somewhere in @INC
    use Ado::BuildPlugin;
    my $builder = Ado::BuildPlugin->new(..);
    $builder->create_build_script();

=head1 DESCRIPTION

This is a subclass of L<Module::Build>. 
We use L<Module::Build::API> to add custom functionality 
so we can install Ado  and its plugins in a location chosen by the user.
To use this module for installing your plugins
Build.PL should some how find it in @INC (may be via C<$ENV{PERL5LIB}>).

This module and L<Ado::Build> exist because of the additional install paths
that we use beside C<lib> and C<bin>. These modules also can serve as examples 
for your own builders if you have some custom things to do during 
build, test, install and even if you need to add a new C<ACTION_*> 
to your setup.


=head1 METHODS

Ado::BuildPlugin inherits all methods from L<Module::Build>. 
It also imports C<create_build_script>, C<process_etc_files>, 
C<process_public_files>, C<process_templates_files> from L<Ado::Build>.


=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013-2014 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

