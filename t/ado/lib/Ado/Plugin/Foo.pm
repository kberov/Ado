#t/ado/lib/Ado/Plugin/Foo.pm
package Ado::Plugin::Foo;
use Mojo::Base 'Ado::Plugin';

# prefer Mojolicious::Plugin::JSONConfig.
has config_classes => sub { {dummy => 'Mojolicious::Plugin::JSONConfig'} };

sub register {
    my ($self, $app, $config) = @_;

    $self->ext('dummy');    # Set explicitly the extension for the configuration file.
    $self->app($app);       #!Needed in $self->config!

    # Merge passed configuration (usually from etc/ado.conf) with configuration
    # from  etc/plugins/example(.mode?).conf
    $config = $self->{config} = {%{$self->config}, %{($config ? $config : {})}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($config));

    # Do plugin specific stuff
    # here...
    # ...
    return $self;
}
1;
