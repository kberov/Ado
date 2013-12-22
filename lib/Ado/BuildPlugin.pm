package Ado::BuildPlugin;
use 5.014;
use strict;
use warnings FATAL => 'all';
use File::Spec::Functions qw(catdir catfile catpath);
use File::Path qw(make_path);
use File::Copy qw(copy);
use parent 'Module::Build';
use Ado::Build qw(process_etc_files process_public_files process_templates_files);

sub create_build_script {
    my $self = shift;
    $ENV{ADO_HOME} ||= $self->install_base;
    if (!$ENV{ADO_HOME} || !-d catdir($ENV{ADO_HOME}, 'lib')) {
        say <<"MSG";
       Ado was not found!
       Please first install Ado!"
       Do not forget to set \$ADO_HOME environment variable
       so Ado plugins can easily find it!
MSG
        return;
    }
    $self->install_base($ENV{ADO_HOME});
    $self->install_path(arch => catdir($self->install_base, 'lib'));
    for my $be (qw(lib etc public log templates)) {
        next unless -d $be;
        $self->add_build_element($be);
        $self->install_path($be => catdir($self->install_base, $be));
    }
    $self->SUPER::create_build_script();
    return;
}
1;


=pod

=encoding utf8

=head1 NAME

Ado::BuildPlugin - Custom routines for Ado::Plugin::* installation 

=head1 SYNOPSIS

    #Ado must be already installed in $ENV{ADO_HOME} 
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

This module and L<Ado::Build> exist because of the additional install paths
that we use beside c<lib> and <bin>. These modules also can serve as examples 
for your own builders if you have some custom things to do during 
build, test, install and even if you need to add a new C<ACTION_*> to your setup.


=head1 METHODS

Ado::BuildPlugin inherits all methods from L<Module::Build> and implements 
the following ones. It also imports C<process_etc_files>, C<process_public_files>,
C<process_templates_files> from L<Ado::Build>.


=head2 create_build_script

Creates a C<Build> script for instaling an L<Ado> plugin.


=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

