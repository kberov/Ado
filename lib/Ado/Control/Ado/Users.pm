package Ado::Control::Ado::Users;
use Mojo::Base 'Ado::Control::Ado';


#available users on this system
sub list {
    my $c     = shift;
    my @range = ($c->param('limit') || 10, $c->param('offset') || 0,);
    my @users = Ado::Model::Users->select_range(@range);

    #content negotiation
    return $c->respond_to(
        json => {json => [map { $_->data } @users],},
        any => {text => '', status => 204}
    );
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Control::Ado::Users - The controller to manage users. 

=head1 SYNOPSIS

#in your browser go to
http://your-host/ado-users/list
#or
http://your-host/ado-users
#and
http://your-host/ado-users/edit/$id
#and
http://your-host/ado-users/add

=head1 DESCRIPTION

Ado::Control::Ado::Users is the controller class for managing users in the
back-office application.

=head1 ATTRIBUTES

L<Ado::Control::Ado::Users> inherits all the attributes from 
<Ado::Control::Ado> and defines the following ones.

=head1 METHODS/ACTIONS
                     
=head2 list

Displays the users this system has.
Uses the request parameters C<limit> and C<offset> to display a range of items
starting at C<offset> and ending at C<offset>+C<limit>.

=head1 SPONSORS

The original author

=head1 SEE ALSO
L<Ado::Control::Ado::Default>,
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

