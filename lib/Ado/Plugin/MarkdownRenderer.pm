package Ado::Plugin::MarkdownRenderer;
use Mojo::Base 'Ado::Plugin';

sub register {
    my ($self, $app, $conf) = @_;
    $self->app($app);    #!Needed in $self->config!

    #Merge passed configuration with configuration
    #from  etc/ado.conf and etc/plugins/mark_down_renderer.conf
    $conf = {%{$self->config}, %{$conf ? $conf : {}}};
    $conf->{md_renderer} ||= 'Text::MultiMarkdown';

    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($conf));

    #TODO: Implementation

    $app->load_routes($conf->{routes});
    return $self;
}

sub md_to_html {
    my $c = shift;    #current controller
    state $config      = $c->config('plugins')->{markdown_renderer};
    state $md_renderer = $config->{md_renderer};

    my $e = Mojo::Loader->load($md_renderer);
    if (ref $e) {
        Carp::cluck("Exception: $e");
        return '';
    }
    elsif ($e) {
        my $e2 = Mojo::Loader->load($md_renderer);
        Carp::cluck(
            ref $e2
            ? "Exception: $e2"
            : "$md_renderer not found."
        ) if $e2;
        return '';
    }
    $md_renderer->new();
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Plugin::MarkDownRenderer - Render static files in markdown format


=head1 SYNOPSIS

  #Open $MOJO_HOME/etc/plugins/markdown-renderer.conf and describe your routes
  routes     => [
        {route => '/doc/*md_file', via => ['GET'],  
          to => 'doc#show',},
        #your own great enterprise wiki
        {route => '/wiki/*md_file', via => ['GET'], 
          to => 'wiki#show',},
        #...
        ],

=head1 DESCRIPTION

L<Ado::Plugin::MarkdownRenderer> is a markdown renderer, rawr!

You only need to create a controller for your enterprise wiki and use
the L</md_to_html> helper provided by this plugin. 
See Ado::Control::Doc for an example.

The code of this plugin is a good example for learning to build new plugins,
you're welcome to fork it.

=head1 HELPERS

=head2 md_to_html

Given a Markdown string returns the HTML produced by L<Text::Markdown/markdown>.

=cut
