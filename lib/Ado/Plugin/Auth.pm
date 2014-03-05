package Ado::Plugin::Auth;
use Mojo::Base 'Ado::Plugin';

sub register {
    my ($self, $app, $config) = @_;
    $self->app($app);    #!Needed in $self->config!

    #Merge passed configuration (usually from etc/ado.conf) with configuration
    #from  etc/plugins/markdown_renderer.conf
    $config = $self->{config} = {%{$self->config}, %{$config ? $config : {}}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($config));

    #Make sure we have all we need from config files.
    $config->{auth_methods} ||= ['ado', 'facebook'];
    $app->config(auth_methods => $config->{auth_methods});

    # Add helpers
    $app->helper(
        'user' => sub {
            Ado::Model::Users->query("SELECT * from users WHERE login_name='guest'");
        }
    );

    #Load routes if they are passed
    push @{$app->renderer->classes}, __PACKAGE__;
    $app->load_routes($config->{routes})
      if (ref($config->{routes}) eq 'ARRAY' && scalar @{$config->{routes}});

    return $self;
}


# helper used in auth_ado
# authenticates the user and returns true/false
sub digest_auth {
    my $c = shift;

    return 0;
}

# general condition for authenticating users - dispatcher to specific authentication method
sub auth {
    my ($route, $c, $captures, $patterns) = @_;
    $c->debug($route, $c, $captures, $patterns);

    return 1;
}

# condition to locally authenticate a user
sub auth_ado {
    my ($route, $c, $captures, $patterns) = @_;


    return 1;
}

#condition to authenticate a user via facebook
sub auth_facebook {
    my ($route, $c, $captures, $patterns) = @_;


    return 1;
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Plugin::Auth - Authenticate users

=head1 SYNOPSIS


=head1 DESCRIPTION

L<Ado::Plugin::Auth> is a plugin that helps authenticate users to an L<Ado> system.
Users can be authenticated locally or using Facebook, Google, Twitter
and other authentication service-providers.

=head1 OPTIONS

The following options can be set in C<etc/ado.conf>.
You can find default options in C<etc/plugins/auth.conf>.

=head2 auth_methods

This option will enable the listed methods (services) which will be used to 
authenticate a user. The order is important. The services will be listed
in the specified order in the partial template C<authbar.html.ep>
that can be included in any other template on your site.


  #in ado.${\$app->mode}.conf
  plugins =>[
    #...
    {name => 'auth', config => {
        services =>['ado',facebook,...]
      }
    }
  ]

=head1 CONDITIONS

L<Ado::Plugin::Auth> provides the following conditions to be used by routes.

=head2 auth

  #programatically
  $app->routes->route('/ado-users/:action', over => {auth => {ado => 1}});
  $app->routes->route('/ado-users/:action', over =>'auth');
  $app->routes->route('/ado-users/:action', over =>['auth','authz','foo','bar']);

  #in ado.conf or ado.${\$app->mode}.conf
  routes => [
    #...
    {
      route => '/ado-users/:action:id',
      via   => [qw(PUT DELETE)],
      
      # only local users can edit and delete users,
      # and only if they are authorized to do so
      over =>[auth => {ado => 1},'authz'],
      to =>'ado-users#edit'
    }
  ],

Condition used to authenticate users for specific routes.
Additional parameters can be passed to specify the preferred authentication method to be used.
If no parameters are passed the method is guessed from  C<$c-E<gt>param('auth_method')>.

=head2 auth_ado

Same as:

  auth => {ado => 1},

=head2 auth_facebook

Same as:

  auth => {facebook => 1},



=head1 HELPERS

L<Ado::Plugin::Auth> exports the following helpers for use in  
L<Ado::Control> methods and templates.

=head2 user

Returns the current user - C<guest> by default.

  $c->user(Ado::Model::Users->query("SELECT * from users WHERE login_name='guest'"));
  my $current_user = $c->user;

=head2 digest_auth

The helper used in L</auth_ado> condition to authenticate the user.

  if($c->digest_auth){
    #good, continue
  }
  else {
    $c->render(code=>401,text =>'401 Unauthorized')
  }



=head1 METHODS

L<Ado::Plugin::Auth> inherits all methods from
L<Ado::Plugin> and implements the following new ones.


=head2 register

This method is called by C<$app-E<gt>plugin>.
Registers the plugin in L<Ado> application and merges authentication 
configuration from C<$MOJO_HOME/etc/ado.conf> with settings defined in
C<$MOJO_HOME/etc/plugins/auth.conf>. Authentication settings defined in C<ado.conf>
will overwrite those defined in C<plugins/auth.conf>.

=head1 TODO

The following authentication methods are in the TODO list:
facebook, linkedin, google.
Others may be added later.

=head1 SEE ALSO

L<Ado::Plugin>, L<Ado::Manual::Plugins>,L<Mojolicious::Plugins>, 
L<Mojolicious::Plugin>, 

=head1 SPONSORS

The original author

=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2014 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut


__DATA__

@@ partials/authbar.html.ep
%# displayed as a menu item
<div class="right compact menu">
% if (user->login_name eq 'guest') {
  <div class="ui simple dropdown item">
  Login using<i class="dropdown icon"></i>
    <div class="menu">
    % for my $auth(@{app->config('auth_methods')}){
      <a href="<%=url_for("login/$auth")->to_abs %>" class="item">
        <i class="Ⰱ <%=$auth %> icon"></i> <%=ucfirst $auth %>
      </a>
    % }    
    </div>
  </div>
% } else {
  <a href="logout"><i class="sign out icon"></i> <%=user->login_name %></a>
% }
</div>
