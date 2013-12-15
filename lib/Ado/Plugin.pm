package Ado::Plugin;
use Mojo::Util qw(decamelize);
use Mojo::Base 'Mojolicious::Plugin';

has app => sub { Mojo::Server->new->build_app('Mojo::HelloWorld') };
has name => sub {

    #only in Ado::Plugin namespace
    (ref $_[0] || $_[0]) =~ /(\w+)$/ && return $1;
};

sub _get_plugin_config {
    my ($self) = @_;
    state $app = $self->app;
    my $name = $self->name;

    #Only try (plugin specific configuration file).
    my $conf_file = $app->home->rel_dir('etc/plugins/' . decamelize($name) . '.conf');
    if (my $config = eval { Mojolicious::Plugin::Config->new->load($conf_file, {}, $app) }) {
        return $config;
    }
    else {
        Carp::carp("Could not load configuration from file $conf_file! " . $@);
        return {};
    }
}

sub config {
    my ($self, $key) = @_;
    $self->{config} ||= $self->_get_plugin_config();
    return $key
      ? $self->{config}->{$key}
      : $self->{config};
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Plugin - base class for Ado specific plugins. 


=head1 SYNOPSIS

  # CamelCase plugin name
  package Ado::Plugin::MyPlugin;
  use Mojo::Base 'Ado::Plugin';

  sub register {
    my ($self, $app, $conf) = @_;
    $self->app($app);#!Needed in $self->config!
    #Merge passed configuration with configuration 
    #from  etc/ado.conf and etc/plugins/my_plugin.conf
    $conf = {%{$self->config},%{$conf?$conf:{}}};
    # Your magic here! :)
  }


=head1 DESCRIPTION

Ado::Plugin is a base class for Ado specific plugins. 
It provides some methods specific to L<Ado> only.

=head1 ATTRIBUTES

Ado::Plugin provides the following attributes for use by subclases.

=head2 app

  my $app  = $self->app;
  $command = $self->app(MyApp->new);

Application for plugin, defaults to a L<Mojo::HelloWorld> object.

  # Introspect
  say "Template path: $_" for @{$self->app->renderer->paths};

=head2 name

The name - only the plugin name without the namespace.

  $self->name #MyPlugin

=head1 METHODS


Ado::Plugin provides the following methods for use by subclases.

=head2 config

The configuration which is for the plugin only.

  $self->config 
  #everything in '$ENV{MOJO_HOME}/etc/plugins/'.decamelize('MyPlugin').'.conf'
  #or under  $app->config('MyPlugin') 
  #or $app->config('my_plugin') - in this order
  
  my $value = $self->config('key');


=head1 SPONSORS

The original author

=head1 SEE ALSO

L<Ado::Manual::Plugin>, L<Ado::Plugin::Routes>, L<Mojolicious::Plugin>, 
L<Mojolicious::Plugin>, 


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


