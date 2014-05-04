package Ado::Control::Ado::Default;
use Mojo::Base 'Ado::Control::Ado';

##no critic (ProhibitBuiltinHomonyms)
sub index {
    my $c = shift;
    $c->render(text => __PACKAGE__ . '::index', layout => 'default');
    return;
}

sub form {
    my $c = shift;
    $c->render(text => __PACKAGE__ . '::form', layout => 'default');
    return;
}


#available groups on this system
sub groups {
    my $c      = shift;
    my @range  = ($c->param('limit') || 10, $c->param('offset') || 0,);
    my @groups = Ado::Model::Groups->select_range(@range);

    #content negotiation
    return $c->respond_to(
        json => {json => [map { $_->data } @groups],},
        any => {text => '', status => 204}
    );
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Control::Ado::Default - The default controller for the back-office. 

=head1 SYNOPSIS

#in your browser go to
http://your-host/ado/default/index
#or
http://your-host/ado/default
#or
http://your-host/ado

=head1 DESCRIPTION

Ado::Control::Ado::Default is the default controller class for the back-office application.

=head1 ATTRIBUTES

Ado::Control::Ado::Default inherits all the attributes from 
<Ado::Control::Ado> and defines the following ones.

=head1 METHODS/ACTIONS

=head2 index

C<index> is the default action for the back-office application L<Ado::Control::Ado>.

=head2 form

The form action.

=head2 groups

Displays the groups of users this system has.
Uses the request parameters C<from> and C<to> to display a range of items
beginning at C<from> and ending at C<to>.


=head1 SPONSORS

The original author

=head1 SEE ALSO
L<Ado::Control::Ado>,
L<Ado::Control>, L<Mojolicious::Controller>, L<Mojolicious::Guides::Growing/Model_View_Controller>,
L<Mojolicious::Guides::Growing/Controller_class>


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

