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
    my $file_path = $c->stash('md_file');
    $c->debug("md_file: $file_path");
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

  #1. Use one or more markup parsers
  plugins => [
    #...
    'markdown_renderer',
    {name => 'markdown_renderer', config => {
      md_renderer =>'Text::Markup',
      md_options => {
        trac_url      => '/wiki',
        disable_links => [ qw( changeset ticket ) ],
      },
      md_method => 'parse',
      md_helper =>'trac_to_html'
    }},
    #...
  ],

  #2. Describe your routes
  routes     => [
        #markdown_renderer route is already configured
        #in etc/plugins/markdown_renderer.conf.
        
        #Your own great enterprise wiki
        {route => '/wiki/*md_file', via => ['GET'], 
          to => 'wiki#show',},
        #...
        ],
  
  #3. Write your controller
  package Ado::Control::Wiki;
  use Mojo::Base 'Ado::Control';
  #...

=head1 DESCRIPTION

L<Ado::Plugin::MarkdownRenderer> is a markdown renderer, rawr!

You only need to create a controller for your enterprise wiki and use
the L</md_to_html> helper provided by this plugin. 
See L<Ado::Control::Doc> for an example.

You may use this plugin to load and use other markup languages parsers 
and converters to HTML.

The code of this plugin is a good example for learning to build new plugins,
you're welcome to fork it.

=head1 OPTIONS

The following options can be set in C<etc/ado.conf>.
You can find default options in C<etc/plugins/markdown_renderer.conf>.
C<md> prefix is short for "markup document" or "markdown".

=head2 md_renderer

  md_renderer => 'Text::MultiMarkdown',

The class to load. This option exists because the user may want to use
L<Text::Markdown> or L<Text::Markup> instead.

=head2  md_method

  md_method => 'markdown',

Method that will be used internally to produce the C<$HTML>.
Can also be a code reference.
First parameter is the md_renderer instance and the 
second is the markdown text.

=head2 md_options

  md_options => {
      use_wikilinks => 1,
      base_url      => '/doc/bg/',
  },

These options will be passed to the md_renderer constructor. 
They are specific for each markup parser so look at it's documentation.

=head2 md_helper

  md_helper => 'md_to_html',

Default helper name. You may want to change this if you want to have
different helpers for different markup converters,
configurations, applications etc...

=head1 HELPERS

L<Ado::Plugin::MarkdownRenderer> exports the following helper for use in  
L<Ado::Control> methods and templates.

=head2 md_to_html

Given a Markdown string returns the HTML produced by the renderer - 
L<Text::MultiMarkdown> by default. 
You may want to use your own helper name. See L</md_helper>.

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

Register renderer and helper in L<Ado>.

=head1 SPONSORS

The original author

Become a sponsor and help make L<Ado> the ERP for the enterprise!

=head1 SEE ALSO

L<Ado::Control::Doc>, L<Ado::Plugin>, L<Ado::Manual>.

=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut
