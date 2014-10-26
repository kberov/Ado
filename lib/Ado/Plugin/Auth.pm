package Ado::Plugin::Auth;
use Mojo::Base 'Ado::Plugin';

sub register {
    my ($self, $app, $conf) = shift->initialise(@_);

    # Make sure we have all we need from config files.
    $conf->{auth_methods} ||= ['ado', 'facebook'];
    $app->config(auth_methods => $conf->{auth_methods});

    # Add helpers
    $app->helper(login_ado => \&_login_ado);

    # Add conditions
    $app->routes->add_condition(authenticated => \&authenticated);
    $app->routes->add_condition(ingroup => sub { $_[1]->user->ingroup($_[-1]) });

    #Add to classes used for finding templates in DATA sections
    push @{$app->renderer->classes}, __PACKAGE__;
    return $self;
}


# general condition for authenticating users - redirects to /login
sub authenticated {
    my ($route, $c, $captures, $patterns) = @_;
    $c->debug('in condition "authenticated"') if $Ado::Control::DEV_MODE;
    if ($c->user->login_name eq 'guest') {
        $c->session(over_route => $c->url_for($route->name));
        $c->redirect_to('/login');
        return;
    }
    return 1;
}


#expires the session.
sub logout {
    my ($c) = @_;
    $c->session(expires => 1);
    $c->redirect_to('/');
    return;
}

#authenticate a user
sub login {
    my ($c) = @_;

#TODO: add json format

    #prepare redirect url for after login
    unless ($c->session('over_route')) {
        my $base_url = $c->url_for('/')->base;
        my $referrer = $c->req->headers->referrer // $base_url;
        $referrer = $base_url unless $referrer =~ m|^$base_url|;
        $c->session('over_route' => $referrer);
        $c->debug('over_route is ' . $referrer) if $Ado::Control::DEV_MODE;
    }
    return $c->render(status => 200, template => 'login') if $c->req->method ne 'POST';

    #derive a helper name for login the user
    my $auth_method  = Mojo::Util::trim($c->param('auth_method'));
    my $login_helper = 'login_' . $auth_method;
    my $authnticated = 0;
    if (eval { $authnticated = $c->$login_helper(); 1 }) {
        if ($authnticated) {

            # Store a friendly message for the next page in flash
            $c->flash(login_message => 'Thanks for logging in! Wellcome!');

            # Redirect to referrer page with a 302 response
            $c->debug('redirecting to ' . $c->session('over_route'))
              if $Ado::Control::DEV_MODE;
            $c->redirect_to($c->session('over_route'));
            return;
        }
        else {
            unless ($c->res->code // '' eq '403') {
                $c->stash(error_login => 'Wrong credentials! Please try again!');
                $c->render(status => 401, template => 'login');
                return;
            }
        }
    }
    else {
        $c->app->log->error("Unknown \$login_helper:[$login_helper][$@]");
        $c->stash(error_login => 'Please choose one of the supported login methods.');
        $c->render(status => 401, template => 'login');
        return;
    }
    return;
}

#used as helper 'login_ado' returns 1 on success, '' otherwise
sub _login_ado {
    my ($c) = @_;

    #1. do basic validation first
    my $val = $c->validation;
    return '' unless $val->has_data;
    if ($val->csrf_protect->has_error('csrf_token')) {
        delete $c->session->{csrf_token};
        $c->render(error_login => 'Bad CSRF token!', status => 403, template => 'login');
        return '';
    }
    my $_checks = Ado::Model::Users->CHECKS;
    $val->required('login_name')->like($_checks->{login_name}{allow});
    $val->required('digest')->like(qr/^[0-9a-f]{40}$/);
    if ($val->has_error) {
        delete $c->session->{csrf_token};
        return '';
    }

    #2. find the user and do logical checks
    my $login_name = $val->param('login_name');
    my $user       = Ado::Model::Users->by_login_name($login_name);
    if ((not $user->id) or $user->disabled) {
        delete $c->session->{csrf_token};
        $c->stash(error_login_name => "No such user '$login_name'!");
        return '';
    }

    #3. really authnticate the user
    my $checksum = Mojo::Util::sha1_hex($c->session->{csrf_token} . $user->login_password);
    if ($checksum eq $val->param('digest')) {
        $c->session(login_name => $user->login_name);
        $c->user($user);
        $c->app->log->info('$user ' . $user->login_name . ' logged in!');
        delete $c->session->{csrf_token};
        return 1;
    }

    $c->debug('We should not be here! - wrong password') if $Ado::Control::DEV_MODE;
    delete $c->session->{csrf_token};
    return '';
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Plugin::Auth - Authenticate users

=head1 SYNOPSIS

  #in ado.${\$app->mode}.conf
  plugins =>[
    #...
    {name => 'auth', config => {
        auth_methods =>['ado', 'facebook',...],
        routes => [...]
      }
    }
    #...
  ]

=head1 DESCRIPTION

L<Ado::Plugin::Auth> is a plugin that authenticates users to an L<Ado> system.
Users can be authenticated locally or using (TODO!) Facebook, Google, Twitter
and other authentication service-providers.

=head1 OPTIONS

The following options can be set in C<etc/ado.conf>.
You can find default options in C<etc/plugins/auth.conf>.

=head2 auth_methods

This option will enable the listed methods (services) which will be used to 
authenticate a user. The services will be listed in the specified order
in the partial template C<authbar.html.ep> that can be included
in any other template on your site.

  #in ado.${\$app->mode}.conf
  plugins =>[
    #...
    {name => 'auth', config => {
        auth_methods =>['ado', 'facebook',...]
      }
    }
    #...
  ]

=head1 CONDITIONS

L<Ado::Plugin::Auth> provides the following conditions to be used by routes.
To find more about conditions read L<Mojolicious::Guides::Routing/Conditions>.

=head2 authenticated

Condition for routes used to check if a user is authenticated.
Additional parameters can be passed to specify the preferred 
authentication method to be preselected in the login form
if condition redirects to C</login/:auth_method>.

  # add the condition programatically
  $app->routes->route('/ado-users/:action', over => {authenticated=>1});
  $app->routes->route('/ado-users/:action', 
    over => [authenticated => 1, authz => {group => 'admin'}]
  );

  #in ado.conf or ado.${\$app->mode}.conf
  routes => [
    #...
    {
      route => '/ado-users/:action:id',
      via   => [qw(PUT DELETE)],
      
      # only authenticated users can edit and delete users,
      # and only if they are authorized to do so
      over => [authenticated => 1, authz => {group => 'admin'}],
      to =>'ado-users#edit'
    }
  ],

=head2 ingroup

Checks if a user is in the given group. Returns true or false
  
  # in etc/routes.conf or etc/fooplugin.conf
  {
    route => '/vest', 
    via => ['GET'], 
    to => 'vest#screen', 
    over => {authenticated => 1, ingroup => 'foo'},
  }
  # programatically
  $app->routes->route('/ado-users/:action', over => {ingroup => 'foo'});

=head1 HELPERS

L<Ado::Plugin::Auth> provides the following helpers for use in  
L<Ado::Control> methods and templates.



=head1 ROUTES

L<Ado::Plugin::Auth> provides the following routes (actions):

=head2 /login

  /login/:auth_method

If accessed using a C<GET> request displays a login form.
If accessed via C<POST> performs authentication using C<:auth_method>.

=head2 /logout

Expires the session and redirects to the base URL.

  $c->logout();

=head1 TEMPLATES

L<Ado::Plugin::Auth> embeds the following templates. You can run C<ado inflate> and modify them.
Usage examples can be found at L<http://localhost:3000> after starting ado.

=head2 partials/authbar.html.ep

Renders a menu dropdown for choosing methods for signing in.

=head2 partials/login_form.html.ep

Renders a Login form.


=head2 login.html.ep

Renders a page containing the login form.

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

L<Ado::Plugin>, L<Ado::Manual::Plugins>, L<Mojolicious::Plugins>, 
L<Mojolicious::Plugin>, L<Mojolicious::Guides::Routing/Conditions>

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
<div class="right compact menu" id="authbar">
% if (user->login_name eq 'guest') {
  <div class="ui simple dropdown item">
    <i class="sign in icon"></i><%=l('Sign in') %>
    <div class="menu">
    % for my $auth(@{app->config('auth_methods')}){
      <a href="<%=url_for("login/$auth")->to_abs %>" 
        title="<%=ucfirst l($auth) %>" class="item">
        <i class="<%=$auth %> icon"></i>
      </a>
    % }    
    </div>
  </div>
  <div class="ui small modal" id="modal_login_form">
    <i class="close icon"></i>
    %=include 'partials/login_form'
  </div><!-- end modal dialog with login form in it -->
% } else {
  <a class="ui item" href="<%= url_for('logout') %>">
    <i class="sign out icon"></i><%= l('Logout').' ('. user->name .')' %>
  </a>
% }
</div>



@@ partials/login_form.html.ep
  <form class="ui form segment" method="POST" action="" id="login_form">
    <div class="ui header">
    % # Messages will be I18N-ed via JS or Perl on a per-case basis
      Login
    </div>
    % if(stash->{error_login}) {
    <div id="error_login" class="ui error message" style="display:block">
      <%= stash->{error_login} %></div>
    % }
    <div class="field auth_methods">
      % for my $auth(@{app->config('auth_methods')}){
      <span class="ui toggle radio checkbox">
        <input name="_method" type="radio" id="<%=$auth %>_radio"
          %== (stash->{auth_method}//'') eq $auth ? 'checked="checked"' : ''
          value="<%=url_for('login/'.$auth) %>" />
        <label for="<%=$auth %>_radio">
          <i class="<%=$auth %> icon"></i><%=ucfirst l($auth) %>
        </label>
      </span>&nbsp;&nbsp;
      % }
    </div>
    <div class="field">
      <label for="login_name"><%=ucfirst l('login_name')%></label>
      <div class="ui left labeled icon input">
        %= text_field 'login_name', placeholder => l('login_name'), id => 'login_name', required => ''
        <i class="user icon"></i>
        <div class="ui corner label"><i class="icon asterisk"></i></div>
        % if(stash->{error_login_name}) {
        <div id="error_login_name" class="ui error message" style="display:block">
          <%= stash->{error_login_name} %>
        </div>
        % }
      </div>
    </div>
    <div class="field">
      <label for="login_password"><%=l('login_password')%></label>
      <div class="ui left labeled icon input">
        <input type="password" name="login_password" id="login_password" required="" />
        <i class="lock icon"></i>
        <div class="ui corner label"><i class="icon asterisk"></i></div>
      </div>
    </div>
    %= csrf_field
    %= hidden_field 'digest'
    <div class="ui center">
      <button class="ui small green submit button" 
        type="submit"><%=l('Login')%></button>
    </div>
  </form>
%= javascript '/vendor/crypto-js/rollups/sha1.js'
%= javascript '/js/auth.js'

@@ login.html.ep
% layout 'default';
<section class="ui login_form">
%= include 'partials/login_form'
</section>
