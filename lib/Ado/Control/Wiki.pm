package Ado::Control::Wiki;
use Mojo::Base 'Ado::Control';
use Ado::Model::Wiki;

sub index {
	my $self = shift;
	$self->render; 
}

sub read { 
	my $self = shift;

	my $id = $self->stash('id');
	$self->render( text => "Reading wiki page with id: [$id]"); 
}

sub write { 
	my $self = shift;
	$self->render( json => { status => 'todo' });
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Control::Wiki - The controller for the end-user documentation 

=head1 SYNOPSIS

  #in your browser go to
  http://your-host/wiki

=head1 DESCRIPTION

This is a minimal controller to display and browse wiki pages.

=head1 METHODS/ACTIONS

L<Ado::Control::Wiki> inherits all the methods from 
L<Ado::Control> and defines the following ones.

=head2 read

Read wiki page

=head2 write

Save wiki page

=head1 SPONSORS

Become a sponsor and help make L<Ado> the ERP for the enterprise!

=head1 SEE ALSO

L<Ado::Control>, L<Mojolicious::Controller>, 
L<Mojolicious::Guides::Growing/Model_View_Controller>,
L<Mojolicious::Guides::Growing/Controller_class>

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