package Ado::Plugin;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::Util qw(decamelize class_to_path);
File::Spec::Functions->import(qw(catfile catdir));

has app => sub { Mojo::Server->new->build_app('Ado') };
has name => sub {

    # Only the last word of the plugin's package name
    (ref $_[0] || $_[0]) =~ /(\w+)$/ && return $1;
};

#has config_dir => sub { $_[0]->app->home->rel_dir('etc/plugins') };
has config_dir => sub {
    catdir($_[0]->home_dir, 'etc', 'plugins');
};

has home_dir => sub {
    my $p = $INC{class_to_path(ref($_[0]))};

    #/home/you/dev/Ado-Plugin-Foo/lib/Ado/Plugin/Foo.pm
    $p =~ s|[\\/][^/]+[\\/]Ado[\\/]Plugin[\\/].*$||x;
    return $p;
};
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
    if (-f (my $mf = catfile($config_dir, "$name.$mode.$ext"))) {
        my $cmode = eval { $config_class->new->load($mf, {}, $app) };
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
    my ($self, $key, $value) = @_;
    $self->{config} //= $self->_get_plugin_config();
    if (defined $value) {
        $self->{config}->{$key} = $value;
        return $self->{config};
    }
    return $key
      ? $self->{config}->{$key}
      : $self->{config};
}

# one place for initialising plugins in register()
sub initialise {
    my ($self, $app, $conf) = @_;
    return if $self->{_initialised};
    $self->app($app);    #!Needed in $self->config!
    state $mode = $app->mode;

    #Merge passed configuration with configuration
    #from  etc/ado.conf and etc/plugins/$name.conf
    for my $k (keys %$conf) { $self->config($k => $conf->{$k}); }
    $conf = $self->config;
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($conf))
      if ($mode eq 'development');

    # Add namespaces if defined.
    push @{$app->routes->namespaces}, @{$conf->{namespaces}}
      if @{$conf->{namespaces} || []};

    # Load routes if defined.
    $app->load_routes($conf->{routes}) if (@{$conf->{routes} || []});

    # Add templates folder if differs from app templates
    my $templates_dir = catdir($self->home_dir, 'templates');
    if ((!List::Util::first { $templates_dir eq $_ // '' } @{$app->renderer->paths})
        && -d $templates_dir)
    {
        push @{$app->renderer->paths}, $templates_dir;
    }

    # Add plugin specific public folder if differs from app public
    my $public_dir = catdir($self->home_dir, 'public');
    if ((!List::Util::first { $public_dir eq $_ // '' } @{$app->static->paths})
        && -d $public_dir)
    {
        push @{$app->static->paths}, $public_dir;
    }


    $self->{_initialised} = 1;
    return ($self, $app, $conf);
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Plugin - base class for Ado specific plugins. 


=head1 SYNOPSIS

Create your plugin like this:

  # CamelCase plugin name is recommended.
  package Ado::Plugin::MyPlugin;
  use Mojo::Base 'Ado::Plugin';

  sub register {
    my ($self, $app, $conf) = shift->initialise(@_);
    
    # Your magic here!.. 
    
    return $self;
  }

but better use L<Ado::Command::generate::adoplugin> to do everything for you.


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

Defaults to C<etc/plugins> relative to the plugin base directory.
This works both while developing a plugin and after installing the plugin.

=head2 config_classes

Returns a hash reference containing C<file-extension =E<gt> class> pairs.
Used to decide which configuration plugin to use depending on the file extension.
The default mapping is:

    {   conf => 'Mojolicious::Plugin::Config',
        json => 'Mojolicious::Plugin::JSONConfig',
        pl   => 'Mojolicious::Plugin::Config'
    };

Using this attribute you can use your own configuration plugin as far as it
supports the L<Mojolicious::Plugin::Config> API.

=head2 ext

Extension used for the plugin specific configuration file. defaults to 'conf';

  my $ext  = $self->ext;

=head2 home_dir

  my $plugin_home = $self->home_dir;

The plugin base directory.
This path works both while developing a plugin and after installing the plugin.
Using the guessed value allows you to have Ado plugins installed at arbitrary paths,
possibly not the same where Ado is installed.
As noted elswhere, Ado plugins can be distributed as separate Ado applications and used
together with other plugins to create custom enterprise-grade systems.

=head2 name

The name - only the last word of the plugin's package name.

  $self->name # MyPlugin

=head1 METHODS

Ado::Plugin provides the following methods for use by subclasses.

=head2 config

The configuration which is for the currently registering plugin only.
In L<Ado> every plugin can have its own configuration file.
When calling this method for the first time it will parse and merge
configuration files for the plugin. Options from mode specific 
configuration file will overwrite options form the generic file.
You usually do not need to invoke this method directly since it is 
invoked in L</initialise>.

  # everything in $self->config_dir.'/$my_plugin.conf'
  # and/or   $self->config_dir.'/$my_plugin.$mode.conf'
  my $config = $self->config; 
  
  #get a config value
  my $value = $self->config('key');
  #set
  my $config = $self->config(foo => 'bar');

=head2 initialise

Used to initialise you plugin and reduce boilerplate code. 

  sub register {
    my ($self, $app, $config) = shift->initialise(@_);
    # ...
  
This method 
should be the first invoked in your L<Mojolicious::Plugin/register> method. 
If you need to do some very custom stuff, you are free to implement the
initialisation yourself.

Currently this method does the following:

=over

=item * Merges configurations (invokes L</config>).

=item * Pushes C<@{$conf-E<gt>{namespaces}}> to C<$app-E<gt>routes-E<gt>namespaces> 
if additional namespaces are defined in configuration file.

=item * Loads routes if defined in configuration file.

=item * Pushes the plugin C<templates> directory to C<@{app-E<gt>renderer-E<gt>paths}>
(if it exists and is not the same as Ado's one) so the templates can be found by
L<Ado> while developing your plugin.

=item * Pushes the plugin C<public> directory to C<@{app-E<gt>static-E<gt>paths}>
(if it exists and is not the same as Ado's one) so the templates can be found by
L<Ado> while developing your plugin.

=item * Returns C<($self, $app, $config)>.

=back

Look at some of the configuration files of the plugins that come with L<Ado>.


=head1 SEE ALSO

L<Ado::Manual::Plugins>, L<Mojolicious::Plugin>,
L<Ado::Plugin::AdoHelpers>, L<Ado::Plugin::Auth>, L<Ado::Plugin::I18n>,
L<Ado::Plugin::MarkdownRenderer>, L<Ado::Plugin::Routes>, 
L<Ado::Command::generate::adoplugin>.

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
