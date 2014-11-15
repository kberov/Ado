package Ado::Plugin::Auth;
use Mojo::Base 'Ado::Plugin';
use Mojo::Util qw(class_to_path);

sub register {
    my ($self, $app, $conf) = shift->initialise(@_);

    # Make sure we have all we need from config files.
    $conf->{auth_methods} ||= ['ado'];
    $app->helper(login_ado => \&_login_ado);

    $app->config(auth_methods => $conf->{auth_methods});
    $app->config(ref($self)   => $conf);


    #OAuth2 providers
    my @auth_methods = @{$conf->{auth_methods}}[1 .. $#{$conf->{auth_methods}}];

    if (@auth_methods) {
        for my $m (@auth_methods) {
            Carp::croak("Configuration options for authentication method \"$m\" "
                  . "are not enough!. Please add them.")
              if (keys %{$conf->{providers}{$m}} < 2);
        }
        $app->plugin('OAuth2', $conf->{providers});
    }

    # Add helpers
    #oauth2 links - helpers after 'ado'
    $app->helper(login_google => \&_login_google)
      if (List::Util::first { $_ eq 'google' } @auth_methods);

    # Add conditions
    $app->routes->add_condition(authenticated => \&authenticated);
    $app->routes->add_condition(
        ingroup => sub {
            $_[1]->debug("is user " . $_[1]->user->name . " in  group $_[-1]?")
              if $Ado::Control::DEV_MODE;
            return $_[1]->user->ingroup($_[-1]);
        }
    );
    $app->hook(
        after_user_add => sub {
            my ($c, $user, $raw_data) = @_;
            $app->log->info($user->description . ' $user->id ' . $user->id . ' added!');
            $c->debug('new user created with arguments:' . $c->dumper($user->data, $raw_data))
              if $Ado::Control::DEV_MODE;
        }
    );

    #Add this package to classes searched for templates in DATA sections
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
    my $auth_method = Mojo::Util::trim($c->param('auth_method'));

    return $c->render(status => 200, template => 'login')
      if $c->req->method ne 'POST' && $auth_method eq 'ado';

    #derive a helper name for login the user
    my $login_helper = 'login_' . $auth_method;
    my $authnticated = 0;
    if (eval { $authnticated = $c->$login_helper(); 1 }) {
        if ($authnticated) {

            # Store a friendly message for the next page in flash
            $c->flash(login_message => 'Thanks for logging in! Welcome!');

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

#used as helper within login()
# this method is called as return_url after the user
# agrees or denies access for the application
sub _login_google {
    my ($c) = @_;
    state $app = $c->app;
    my $provider  = $c->param('auth_method');
    my $providers = $app->config('Ado::Plugin::Auth')->{providers};
    $providers->{$provider}{redirect_uri} = '' . $c->url_for("/")->to_abs;

    #second call should get the token it self
    my $access_token = $c->get_token($provider, %{$providers->{$provider}});
    $c->debug("in _login_google \$acc_token: " . ($access_token || 'no'));
    $c->debug("in _login_google error from provider: " . ($c->param('error') || 'no error'));

    #When we have an 'access_denied' from provider we get a reference to $c and not a false value!
    if ($access_token && !ref($access_token)) {    #Athenticate, create and login the user.
        return _create_or_authenticate_google_user($c, $access_token, $providers->{$provider});
    }
    else {
        #Redirect to front-page and say sorry
        # We are very sorry but we need to know you are a reasonable human being.
        $c->flash(error_login => $c->l('oauth2_sorry') . ($c->param('error') || ''));
        $c->debug('no token sorry');
        $c->res->code(307);    #307 Temporary Redirect
        $c->redirect_to('/');
    }
    return;
}

sub _authenticate_oauth2_user {
    my ($c, $user, $time) = @_;
    if (   $user->disabled
        || ($user->stop_date != 0 && $user->stop_date < $time)
        || $user->start_date > $time)
    {
        $c->flash(login_message => $c->l('oauth2_disabled'));
        $c->redirect_to('/');
        return;
    }
    $c->session(login_name => $user->login_name);
    $c->user($user);
    $c->app->log->info('$user ' . $user->login_name . ' logged in!');
    return 1;
}

sub _create_or_authenticate_google_user {
    my ($c, $access_token, $provider) = @_;

    #make request for the user info
    my $token_type = 'Bearer';
    my $ua         = Mojo::UserAgent->new;
    my $user_info =
      $ua->get($provider->{info_url} => {Authorization => "$token_type $access_token"})
      ->res->json;
    my $U = 'Ado::Model::Users';
    state $sql = $U->SQL('SELECT') . ' WHERE email=?';
    my $user = $U->query($sql, $user_info->{email});
    my $time = time;

    if ($user->id) {
        return _authenticate_oauth2_user($c, $user, $time);
    }
    else {
        #create the user
        my %args = ();
        $args{email}      = $user_info->{email};
        $args{login_name} = $time . $user_info->{email};
        $args{login_name} =~ s/\@.+//;
        $args{login_password} =
          Mojo::Util::sha1_hex($args{login_name} . Ado::Sessions->generate_id());
        $args{first_name}  = $user_info->{given_name};
        $args{last_name}   = $user_info->{family_name};
        $args{description} = "Registered via $provider->{info_url}!";
        $args{created_by}  = $args{changed_by} = 1;
        $args{start_date}  = $args{disabled} = $args{stop_date} = 0;
        my $app = $c->app;

        if ($user = $U->add(%args)) {
            $app->plugins->emit_hook(after_user_add => $c, $user, $user_info);
            $c->user($user);
            $c->session(login_name => $user->login_name);
            $app->log->info($user->description . ' $user ' . $user->login_name . ' logged in!');
            $c->flash(login_message => $c->l('oauth2_wellcome'));
            $c->redirect_to('/');
            return 1;
        }
        else {
            $app->log->error($@);
            return;
        }
    }
    return;
}


# Redirects to Consent screen
sub authorize {
    my ($c)    = @_;
    my $m      = $c->param('auth_method');
    my $params = $c->app->config('Ado::Plugin::Auth')->{providers}{$m};
    $params->{redirect_uri} = '' . $c->url_for("/login/$m")->to_abs;

    #This call will redirect the user to the provider Consent screen.
    $c->redirect_to($c->get_authorize_url($m, %$params));
    return;
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Plugin::Auth - Passwordless user authentication for Ado

=head1 SYNOPSIS

  #in etc/ado.$mode.conf
  plugins =>[
    #...
    'auth',
    #...
  ],

=head1 DESCRIPTION

L<Ado::Plugin::Auth> is a plugin that authenticates users to an L<Ado> system.
Users can be authenticated locally or using (TODO!) Facebook, Github, Twitter
and other authentication service-providers. 

Note that the user's pasword is never sent over the network. When using the local
authentication method (ado) a digest is prepared in the browser using JavaScript.
The digest is sent and compared on the server side. The digest is different in
every POST request. The other authentication methods use the services provided by
well known service providers like Google, Facebook, Github etc. To use external
authentication providers the module L<Mojolicious::Plugin::OAuth2> needs to be
installed.

=head1 CONFIGURATION

The following options can be set in C<etc/plugins/auth.$mode.conf>.
You can find default options in C<etc/plugins/auth.conf>.

=head2 auth_methods

This option will enable the listed methods (services) which will be used to 
authenticate a user. The services will be listed in the specified order
in the partial template C<authbar.html.ep> that can be included
in any other template on your site.

  #in etc/plugins/auth.$mode.conf
  {
    #methods which will be displayed in the "Sign in" menu
    auth_methods => ['ado', 'google'],
  }

=head2 providers

A Hash reference with keys representing names of providers (same as auth_methods)
and values, containing the configurations for the specific providers.
This option will be merged with already defined providers by
L<Mojolicious::Plugin::OAuth2>.
Add the rest of the needed configuration options to auth.development.conf or
auth.production.conf only because this is highly sensitive and application
specific information.

  #Example for google:
  google =>{
      #client_id
      key =>'123456654321abcd.apps.googleusercontent.com',
      secret =>'Y0uRS3cretHEre',
      scope=>'profile email',
      info_url => 'https://www.googleapis.com/userinfo/v2/me',
      },

=head2 routes

Currently defined routes are described in L</ROUTES>.

=head1 CONDITIONS

L<Ado::Plugin::Auth> provides the following conditions to be used by routes.
To find more about conditions read L<Mojolicious::Guides::Routing/Conditions>.

=head2 authenticated

Condition for routes used to check if a user is authenticated.

=cut

#TODO:?
#Additional parameters can be passed to specify the preferred
#authentication method to be preselected in the login form
#if condition redirects to C</login/:auth_method>.

=pod

  # add the condition programatically
  $app->routes->route('/ado-users/:action', over => {authenticated=>1});
  $app->routes->route('/ado-users/:action', 
    over => [authenticated => 1, ingroup => 'admin']
  );

  #in etc/ado.$mode.conf or etc/plugins/foo.$mode.conf
  routes => [
    #...
    {
      route => '/ado-users/:action:id',
      via   => [qw(PUT DELETE)],
      
      # only authenticated users can edit and delete users,
      # and only if they are authorized to do so
      over => [authenticated => 1, ingroup => 'admin'],
      to =>'ado-users#edit'
    }
  ],

=head2 ingroup

Checks if a user is in the given group. Returns true or false
  
  # in etc/plugins/routes.conf or etc/plugins/foo.conf
  {
    route => '/vest', 
    via => ['GET'], 
    to => 'vest#screen', 
    over => [authenticated => 1, ingroup => 'foo'],
  }
  # programatically
  $app->routes->route('/ado-users/:action', over => {ingroup => 'foo'});

=head1 HELPERS

L<Ado::Plugin::Auth> provides the following helpers for use in  
L<Ado::Control> methods and templates.

=head2 login_ado

Finds and logs in a user locally. Returns true on success, false otherwise.

=head2 login_google

Called via C</login/google>. Finds an existing user and logs it in via Google.
Creates a new user if it does not exist and logs it in via Google.
The new user can login only via Google.
Returns true on success, false otherwise.

=head1 HOOKS

Ado::Plugin::Auth emits the following hooks.

=head2 after_user_add

  $app->hook(after_build_tx => sub {
    my ($c, $user, $raw_data) = @_;
    my $group = $user->add_to_group(ingroup=>'vest');
    ...
  });

In your plugin you can define some functionality to be executed right after a user
is added. For example add a user to a group after registration. Passed the controller,
the newly created C<$user> and the $raw_data used to create the user.

=head1 ROUTES

L<Ado::Plugin::Auth> provides the following routes (actions):

=head2 /authorize/:auth_method

Redirects to an OAuth2 provider consent screen where the user can authorize L<Ado>
to use his information or not.
Currently L<Ado> supports only Google.

=head2 /login

  /login/ado

If accessed using a C<GET> request displays a login form.
If accessed via C<POST> performs authentication using C<ado> system database.

  /login/google

Google consent screen redirects to this action. 
This action is handled by L</login_google>.


=head2 /logout

Expires the session and redirects to the base URL.

  $c->logout();

=head1 TEMPLATES

L<Ado::Plugin::Auth> embeds the following templates.
You can run C<ado inflate> and modify the inflated files.
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
C<$MOJO_HOME/etc/plugins/auth.conf>. Authentication settings defined in
C<plugins/auth.$mode.conf> will override those defined in C<plugins/auth.conf>.
Authentication settings defined in C<ado.conf> will override both.

=head1 TODO

The following authentication methods are in the TODO list:
facebook, linkedin, github.
Others may be added later.

=head1 SEE ALSO

L<Mojolicious::Plugin::OAuth2>,
L<Ado::Plugin>, L<Ado::Manual::Plugins>, L<Mojolicious::Plugins>, 
L<Mojolicious::Plugin>, L<Mojolicious::Guides::Routing/Conditions>

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
% my $providers = config('Ado::Plugin::Auth')->{providers};
<div class="right compact menu" id="authbar">
% if (user->login_name eq 'guest') {
  <div class="ui simple dropdown item">
    <i class="sign in icon"></i><%=l('Sign in') %>
    <div class="menu">
    % my $action ='login';
    % for my $auth (@{app->config('auth_methods')}) {
      % if ($auth ne 'ado') {$action ='authorize';}
      <a href="<%=url_for("/$action/$auth")->to_abs %>" 
        title="<%=ucfirst l($auth) %>" class="item <%= $auth %>">
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
      % for my $auth(@{config('auth_methods')}){
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
