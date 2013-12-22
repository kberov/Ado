package Ado::Control::Ado::Users;
use Mojo::Base 'Ado::Control::Ado';


#available users on this system
sub list {
    my $c = shift;
    $c->require_formats(['json']) || return;
    my $args = Params::Check::check(
        {   limit => {
                allow => sub { $_[0] =~ /^\d+$/ ? 1 : ($_[0] = 20); }
            },
            offset => {
                allow => sub { $_[0] =~ /^\d+$/ ? 1 : defined($_[0] = 0); }
            },
        },
        {   limit  => $c->req->param('limit')  || 20,
            offset => $c->req->param('offset') || 0,
        }
    );

    $c->res->headers->content_range(
        "users $$args{offset}-${\($$args{limit} + $$args{offset})}/*");
    $c->debug("rendering json only [$$args{limit}, $$args{offset}]");

    #content negotiation
    return $c->respond_to(
        json => $c->list_for_json(
            [$$args{limit}, $$args{offset}],
            [Ado::Model::Users->select_range($$args{limit}, $$args{offset})]
        )
    );
}

sub add {
    return shift->render(text => 'not implemented...');
}

sub show {
    return shift->render(text => 'not implemented...');
}

sub update {
    return shift->render(text => 'not implemented...');
}

sub disable {
    return shift->render(text => 'not implemented...');
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
This method serves the resource C</ado-users/list.json>.
If other format is requested returns status 415 with C<Content-location> header
pointing to the proper URI.
See L<http://www.w3.org/Protocols/rfc2616/rfc2616-sec10.html#sec10.4.16> and
L<http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html#sec14.14>.

=head2 add

Adds a user to the table users. Not implemented yet

=head2 show

Displays a user. Not implemented yet

=head2 update

Updates a user. Not implemented yet

=head2 disable

Disables a user. Not implemented yet

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

