package Ado::Plugin::Wiki;
use Mojo::Base 'Ado::Plugin';
use Ado::Model::Wiki;

sub register {
    my ($self, $app, $config) = @_;
    $self->app($app);
    $app->log->debug("Ado::Plugin::Wiki has been loaded.");
    $config = $self->{config} = {%{$self->config}, %{$config ? $config : {}}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($config));
    $app->load_routes($config->{routes})
      if (ref($config->{routes}) eq 'ARRAY' && scalar @{$config->{routes}});

    
    $app->log->debug("Initializing wiki database");
    Ado::Model::Wiki->init;

    return $self;
}


1;
