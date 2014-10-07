package Ado::Plugin::AdoHelpers;
use Mojo::Base 'Ado::Plugin';

sub register {
    my ($self, $app, $conf) = shift->initialise(@_);

    # Add helpers
    $app->helper(
        user => sub {
            Ado::Model::Users->by_login_name(shift->session->{login_name} //= 'guest');
        }
    );

    # http://irclog.perlgeek.de/mojo/2014-10-03#i_9453021
    $app->helper(to_json => sub { Mojo::JSON::to_json($_[1]) });

    return $self;
}


1;

=encoding utf8

=head1 NAME

Ado::Plugin::AdoHelpers - Default Ado helpers plugin

=head1 SYNOPSIS

  # Ado
  $self->plugin('AdoHelpers');

  # Mojolicious::Lite
  plugin 'AdoHelpers';

=head1 DESCRIPTION

L<Ado::Plugin::AdoHelpers> is a collection of renderer helpers for
L<Ado>.

This is a core plugin, that means it is always enabled and its code a good
example for learning to build new plugins, you're welcome to fork it.

See L<Ado::Manual::Plugins/PLUGINS> for a list of plugins that are available
by default.

=head1 HELPERS

L<Ado::Plugin::AdoHelpers> implements the following helpers.

=head2 to_json

  my $chars = $c->to_json({name =>'Петър',id=>2});
  $c->stash(user_as_js => $chars);
  # in a javascript chunk of a template
  var user = <%== $user_as_js %>;
  var user_group_names = <%== to_json([user->ingroup]) %>;

Suitable for preparing JavaScript
objects from Perl references that will be used from stash and in templates.

=head2 user

Returns the current user - C<guest> for not authenticated users.

  $c->user(Ado::Model::Users->query("SELECT * from users WHERE login_name='guest'"));
  #in a controller action:
  my $current_user = $c->user;
  #in a template:
  <h1>Hello, <%=user->name%>!</h1>

=head1 METHODS

L<Ado::Plugin::AdoHelpers> inherits all methods from
L<Ado::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Ado->new);

Register helpers in L<Ado> application.




=head1 SEE ALSO

L<Ado::Plugin>, L<Mojolicious::Plugins>, L<Mojolicious::Plugin>, 


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
