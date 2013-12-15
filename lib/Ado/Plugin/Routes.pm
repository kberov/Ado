package Ado::Plugin::Routes;
use Mojo::Base 'Ado::Plugin';

sub register {
    my ($self, $app, $conf) = @_;
    $self->app($app);    #!Needed in $self->config!

    #Merge passed configuration with configuration
    #from  etc/ado.conf and etc/plugins/routes.conf
    $conf = {%{$self->config}, %{$conf ? $conf : {}}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($conf));

    # My magic here! :)
    push @{$app->routes->namespaces}, @{$conf->{namespaces}}
      if @{$conf->{namespaces} || []};
    $app->load_routes($conf->{routes});
    return $self;
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Plugin::Routes - Keep routes separately.


=head1 SYNOPSIS

  #Open $MOJO_HOME/etc/plugins/routes.conf and describe your routes
  routes     => [
        {route => '/ado-users', via => ['GET'],  
          to => 'ado-users#list',},
        {route => '/ado-users', via => ['POST'], 
          to => 'ado-users#add',},
        ...

=head1 DESCRIPTION

Ado::Plugin::Routes allows you to define your routes in a separate file
C<$MOJO_HOME/etc/plugins/routes.conf>. In the configuration file you can also use
the B<C<app>> keyword and add complex routes as you would do directly in the code.

=head1 METHODS


L<Ado::Plugin::Routes> inherits all methods from
L<Ado::Plugin> and implements the following new ones.


=head2 register

This method is called by C<$app-E<gt>plugin>.
Registers the plugin in L<Ado> application and merges routes 
configuration from C<$MOJO_HOME/etc/ado.conf> with routes defined in
C<$MOJO_HOME/etc/plugins/routes.conf>. Routes defined in C<ado.conf>
can overrwite those defined in C<plugins/routes.conf>.

=head1 SEE ALSO

L<Mojolicious::Guides::Routing>, L<Mojolicious::Routes>, L<Ado::Plugin>, L<Ado::Manual::Plugin>,L<Mojolicious::Plugins>, 
L<Mojolicious::Plugin>, 


=head1 SPONSORS

The original author

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


