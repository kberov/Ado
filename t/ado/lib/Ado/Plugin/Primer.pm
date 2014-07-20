#t/ado/lib/Ado/Plugin/Primer.pm
package Ado::Plugin::Primer;
use Mojo::Base 'Ado::Plugin';

sub register {
    my ($self, $app, $config) = @_;

    # prefer Mojolicious::Plugin::JSONConfig.
    $self->ext('json');    # Set the extension for the configuration file.
    $self->app($app);      #!Needed in $self->config!

    # Merge passed configuration (usually from etc/ado.conf) with configuration
    # from  etc/plugins/example(.mode?).conf
    $config = $self->{config} = {%{$self->config}, %{$config ? $config : {}}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($config));

    # Do plugin specific stuff
    # here...
    # ...
    return $self;
}
1;
