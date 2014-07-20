package Ado::Plugin;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(decamelize decode);
File::Spec::Functions->import(qw(catfile catdir));

has app => sub { Mojo::Server->new->build_app('Mojo::HelloWorld') };
has name => sub {

    # Only the last word of the plugin's package name
    (ref $_[0] || $_[0]) =~ /(\w+)$/ && return $1;
};

has config_dir => sub { $_[0]->app->home->rel_dir('etc/plugins') };
has ext => 'conf';

has config_classes => sub {
    {   conf => 'Mojolicious::Plugin::Config',
        json => 'Mojolicious::Plugin::JSONConfig',
        pl   => 'Mojolicious::Plugin::Config'
    };
};

sub _get_plugin_config {
    my ($self) = @_;
    state $app    = $self->app;
    state $mode   = $app->mode;
    state $home   = $app->home;
    state $loader = Mojo::Loader->new;

    my $config_dir   = $self->config_dir;
    my $ext          = $self->ext;
    my $name         = decamelize($self->name);
    my $config       = {};
    my $config_class = $self->config_classes->{$ext};
    if (my $e = $loader->load($config_class)) {
        Carp::croak ref $e ? "Exception: $e" : $config_class . ' - Not found!';
    }

    # Try plugin specific configuration file.
    if (-f (my $f = catfile($config_dir, "$name.$ext"))) {
        $config = eval { $config_class->new->load($f, {}, $app) };
        Carp::croak($@) unless $config;
    }

    # Mode specific plugin config file
    my $mfile = catfile($config_dir, "$name.$mode.$ext");

    if (   (-f $mfile)
        && (my $cmode = eval { $config_class->new->load($mfile, {}, $app) }))
    {
        Carp::croak($@) unless $cmode;
        return {%$config, %$cmode};    #merge
    }
    else {
        return $config;
    }
    return $config;
}

#plugin configuration getter
sub config {
    my ($self, $key) = @_;
    $self->{config} //= $self->_get_plugin_config();
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
    #Merge passed configuration with plugin configuration from files 
    #from  etc/ado.conf and etc/plugins/my_plugin.conf
    $conf = {%{$self->config},%{$conf?$conf:{}}};
    # Your magic here! 
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

=head2 config_dir

Path to plugin directory.

  $self->config_dir($app->home->rel_dir('etc/plugins'));

Defaults to C<$ENV{MOJO_HOME}/etc/plugins>.

=head2 config_classes

Returns a hash reference contining C<file-extension =E<gt> class> pairs.
Used to decide which configuration plugin to use depending on the file extension.
The default mapping is:

    {   conf => 'Mojolicious::Plugin::Config',
        json => 'Mojolicious::Plugin::JSONConfig',
        pl   => 'Mojolicious::Plugin::Config'
    };

=head2 ext

Extension used for the plugin specific configuration file. defaults to 'conf';

  my $ext  = $self->ext;

=head2 name

The name - only the last word of the plugin's package name.

  $self->name # MyPlugin



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


