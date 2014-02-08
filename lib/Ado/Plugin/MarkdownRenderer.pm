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
    my ($c, $config) = @_;

    my $md_renderer = $config->{md_renderer};
    my $e           = Mojo::Loader->load($md_renderer);
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
    return $md_renderer->new(%{$config->{md_renderer}{options}})->markdown();

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

=head1 OPTIONS

=head2 md_renderer

  md_renderer => 'Text::MultiMarkdown',

  The class to load. This option exists because hte use may want to use
  L<Text::Markdown> or L<Text::Markup> instead.

=head2  md_method

  md_method => 'markdown',

Method that will be used internally to produce the C<$HTML>.
Can also be a code referrence.
First paramether is the md_renderer instance and the 
second is the markdown text.


=head1 HELPERS

L<Ado::Plugin::MarkdownRenderer> exports the following helper for use in  
L<Ado::Control> methods and templates.

=head2 md_to_html

Given a Markdown string returns the HTML produced by the renderer - 
L<Text::Markdown> by default.

  #Markdown from $MOJO_HOME/public/doc/bg/intro.md
  #http://example.com/doc/bg/intro.md
  my $html = $c->md_to_html(); 

  my $html = $c->md_to_html($markdown); 

  % #in a template
  <%= md_to_html();%>

=head1 METHODS

L<Ado::Plugin::MarkdownRenderer> inherits all methods from
L<Ado::Plugin> and implements the following new ones.

=head2 register

  my $route = $plugin->register(Ado->new);
  my $route = $plugin->register(Ado->new, {options => {...}});

Register renderer and helper in L<Mojolicious> application.

=head1 SEE ALSO

L<Ado::Plugin>, L<Ado::Manual>.

=cut
