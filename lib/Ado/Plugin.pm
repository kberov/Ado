package Ado::Plugin;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(decamelize decode);
File::Spec::Functions->import(qw(catfile catdir));

has app => sub { Mojo::Server->new->build_app('Mojo::HelloWorld') };
has name => sub {

    #only the last word
    (ref $_[0] || $_[0]) =~ /(\w+)$/ && return $1;
};

has plugins_dir => sub { $_[0]->app->home->rel_dir('etc/plugins') };

sub _get_plugin_config {
    my ($self) = @_;
    state $app         = $self->app;
    state $mode        = $app->mode;
    state $home        = $app->home;
    state $plugins_dir = $self->plugins_dir;
    my $name   = decamelize($self->name);
    my $config = {};

    # Only try plugin specific configuration file.
    # Read also mode specific configuration file.

    if (-f (my $f = catfile($plugins_dir, "$name.conf"))) {
        $app->log->debug(qq{found configuration file "$f".});
        $config = eval { Mojolicious::Plugin::Config->new->load($f, {}, $app) };
    }
    my $conf_file = catfile($plugins_dir, "$name.$mode.conf");

    if (my $config_mode = eval { Mojolicious::Plugin::Config->new->load($conf_file, {}, $app) }) {
        $app->log->debug(qq{found configuration file "$conf_file".});
        return {%$config, %$config_mode};    #merge
    }
    else {
        return $config;
    }
}

#plugin configuration getter
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

Ado::Plugin provides the following attributes for use by subclasses.

=head2 app

  my $app  = $self->app;
  $command = $self->app(MyApp->new);

Application for plugin, defaults to a L<Mojo::HelloWorld> object.

  # Introspect
  say "Template path: $_" for @{$self->app->renderer->paths};

=head2 name

The name - only the plugin name without the namespace.

  $self->name #MyPlugin

=head2 plugins_dir

Path to plugins directory.

  #$self->app->home->rel_dir('etc/plugins')
  $self->plugins_dir

=head1 METHODS


Ado::Plugin provides the following methods for use by subclasses.

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

L<Ado::Manual::Plugins>, L<Ado::Plugin::Routes>, L<Mojolicious::Plugin>


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


