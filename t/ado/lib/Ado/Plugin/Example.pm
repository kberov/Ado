#t/ado/lib/Ado/Plugin/Example.pm
package Ado::Plugin::Example;
use Mojo::Base 'Ado::Plugin';

sub register {
    my ($self, $app, $config) = @_;
    $self->app($app);    #!Needed in $self->config!

    # Merge passed configuration (usually from etc/ado.conf) with configuration
    # from  etc/plugins/example(.mode?).conf
    $config = $self->{config} = {%{$self->config}, %{$config ? $config : {}}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($config));

    # Do plugin specific stuff
    return $self;
}
1;
