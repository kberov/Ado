package Ado::Control::Ado::Users;
use Mojo::Base 'Ado::Control::Ado';


#available users on this system
sub list {
    my $c = shift;
    my $format = $c->stash('format') || '';
    if ($format ne 'json') {
        my $location = $c->url_for(format => 'json')->to_abs;
        $c->res->headers->add('Content-Location' => $location);
        $location = $c->link_to($location, {format => 'json'});
        return $c->render(
            inline => "415 - Unsupported Media Type $format. Please try $location!",
            status => 415
        );
    }
    $c->debug('rendering json only');

    my @range = ($c->param('limit') || 10, $c->param('offset') || 0,);
    my @users = Ado::Model::Users->select_range(@range);
    $c->res->headers->content_range("users $range[1]-${\($range[0] + $range[1])}/*");

    my $res = {
        json => {
            links => [
                {   rel  => 'self',
                    href => $c->url_with()->query(limit => $range[0], offset => $range[1])
                },
                {   rel => 'next',
                    href =>
                      $c->url_with()->query(limit => $range[0], offset => $range[0] + $range[1])
                },
                (   $range[1]
                    ? { rel  => 'prev',
                        href => $c->url_for()->query(
                            limit  => $range[0],
                            offset => $range[0] - $range[1]
                        )
                      }
                    : ()
                ),
            ],
            data => [map { $_->data } @users]
        },
    };

    #content negotiation
    return $c->respond_to(json => $res);
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

