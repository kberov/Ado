package Ado::Plugin::MarkdownRenderer;
use Mojo::Base 'Ado::Plugin';

sub register {
    my ($self, $app, $conf) = @_;
    $self->app($app);    #!Needed in $self->config!

    #Merge passed configuration with configuration
    #from  etc/ado.conf and etc/plugins/mark_down_renderer.conf
    $conf = {%{$self->config}, %{$conf ? $conf : {}}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($conf));

    #TODO: Implementation

    $app->load_routes($conf->{routes});
    return $self;
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Plugin::MarkDownRenderer - Render static files in markdown format.


=head1 SYNOPSIS

  #Open $MOJO_HOME/etc/plugins/markdown-renderer.conf and describe your routes
  routes     => [
        {route => '/doc/*md_file', via => ['GET'],  
          to => 'ado-wiki#show',},
        {route => '/wiki/*md_file', via => ['GET'], 
          to => 'ado-wiki#show',},
        ...
        ...

=head1 DESCRIPTION




=cut
