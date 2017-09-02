package Ado::Plugin::MarkdownRenderer;
use Mojo::Base 'Ado::Plugin';
use Mojo::File qw(path);
File::Basename->import('fileparse');
File::Spec::Functions->import(qw(catfile catdir));
Mojo::ByteStream->import('b');

sub register {
    my ($self, $app, $config) = shift->initialise(@_);

    #Make sure we have all we need from config files.
    $config->{md_renderer}      ||= 'Text::MultiMarkdown';
    $config->{md_method}        ||= 'markdown';
    $config->{md_options}       ||= {use_wikilinks => 1,};
    $config->{md_helper}        ||= 'md_to_html';
    $config->{md_root}          ||= $app->home->rel_file('public/doc');
    $config->{md_articles_root} ||= $app->home->rel_file('public/articles');
    $config->{md_file_sufixes}  ||= ['.md'];

    if ($config->{md_renderer} eq 'Text::MultiMarkdown') {
        require Text::MultiMarkdown;
        $app->helper($config->{md_helper} => sub { md_to_html(shift, $config, @_) });
        $app->helper(
            markdown => sub {
                my $c = shift;
                return Text::MultiMarkdown::markdown(@_);
            }
        );

    }

    #make plugin configuration available for later in the app
    $app->config(__PACKAGE__, $config);
    return $self;
}

sub md_to_html {
    my ($c, $config, $file_path) = @_;
    $file_path ||= ($c->stash('md_file') || return '');

    #remove anchors
    $file_path =~ s{[^#]#.+}{};
    unless ($file_path) { $c->reply->not_found() && return '' }
    my $fullname = catfile($config->{md_root}, $file_path);
    $c->debug("md_file: $file_path; \$fullname: $fullname");

    my ($name, $path, $suffix) = fileparse($fullname, @{$config->{md_file_sufixes}});
    my $html_filepath = catfile($path, "$name.html");

    #Reuse previously produced html file if md_file is older than the html file.
    if (   $config->{md_reuse_produced_html}
        && -s $html_filepath
        && (stat($fullname))[9] < (stat($html_filepath))[9])
    {
        $c->debug('Found ' . $html_filepath);
        return b(path($html_filepath)->slurp)->decode;
    }

    #404 Not Found
    my $md_filepath = catfile($path, "$name$suffix");
    unless (-s $md_filepath) { $c->reply->not_found() && return '' }

    my $markdown = path($md_filepath)->slurp;
    my $self_url = $c->url_for()->to_string;
    my %options  = (%{$config->{md_options}}, self_url => $self_url);
    my $html     = $c->markdown($markdown, \%options);
    $c->debug($c->dumper({'%options' => \%options, '$html_filepath' => $html_filepath}));
    path($html_filepath)->spurt($html);
    return b($html)->decode;
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Plugin::MarkDownRenderer - Render markdown to HTML


=head1 SYNOPSIS

  #1. Use one or more markup parsers
  plugins => [
    #...
    #use default configuration
    'markdown_renderer',

    #Create your own Text::Trac based wiki
    {name => 'markdown_renderer', config => {
      md_renderer =>'Text::Trac',
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

L<Ado::Plugin::MarkdownRenderer> is a markdown renderer (маани, маани!)

You only need to create a controller for your enterprise wiki and use
the L</md_to_html> helper provided by this plugin.
See L<Ado::Control::Doc> for an example.

You may use this plugin to load and use other markup languages parsers
and converters to HTML.

The code of this plugin is a good example for learning to build new plugins,
you're welcome to fork it.

=head1 OPTIONS

The following options can be set in C<etc/plugins/markdown_renderer.$mode.conf>
or C<etc/ado.conf>. You can find default options in
C<etc/plugins/markdown_renderer.conf>. C<md_> prefix is short for "markup
document" or "markdown".

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
      base_url      => '/docs',
  },

These options will be passed to the md_renderer constructor.
They are specific for each markup parser so look at it's documentation.

=head2 md_helper

  md_helper => 'md_to_html',

Helper name. You may want to change this if you want to have
different helpers for different markup converters,
configurations, applications etc. in the same ado instance.
Default helper name is L</md_to_html>.

=head2 md_root

  md_root         => app->home->rel_dir('public/doc'),

Directory where the raw files reside.

=head2 md_articles_root

  md_articles_root         => app->home->rel_dir('public/articles'),

Directory used by L<Ado::Control::Articles> where the raw markdown files reside
and where the static HTML files are generated.


=head2 md_file_sufixes

  md_file_sufixes => ['.md'],

File-suffixes supported by your renderer.

=head2 md_reuse_produced_html

  md_reuse_produced_html => 1,

Do not convert files on every request but reuse already produced html files.


=head1 HELPERS

L<Ado::Plugin::MarkdownRenderer> exports the following helpers for use in
L<Ado::Control> methods and templates.

=head2 markdown

Accepts markdown text and options. Returns HTML.
Accepts the same parameters as L<Text::MulltiMarkdown/markdown>

  #in a controller
  $c->render(text=>$c->markdown($text));

  #in a template
  %==markdown($text)

=head2 md_to_html

Given a Markdown string returns C<E<lt>articleE<gt>$htmlE<lt>/articleE<gt>>
produced by the converter - L<Text::MultiMarkdown> by default.
You may want to use your own helper name. See L</md_helper>.

  #Markdown from $MOJO_HOME/public/doc/bg/intro.md
  #http://example.com/doc/bg/intro.md
  my $html = $c->md_to_html();

  #Markdown from arbitrary file
  my $html_string = $c->md_to_html($some_filepath);

  % #in a template
  <%= md_to_html();%>
  % #<article>$html</article>

=head1 METHODS

L<Ado::Plugin::MarkdownRenderer> inherits all methods from
L<Ado::Plugin> and implements the following new ones.

=head2 register

  my $plugin = $app->plugin('markdown_renderer' => $OPTIONS);

Register renderer and helper in L<Ado>. Return $self.

=head1 SPONSORS

The original author

Become a sponsor and help make L<Ado> the ERP for the enterprise!

=head1 SEE ALSO

L<Ado::Control::Doc>, L<Ado::Control::Articles>,
L<Text::MultiMarkdown>, L<http://fletcherpenney.net/multimarkdown/>,
L<MultiMarkdown Guide|https://rawgit.com/fletcher/human-markdown-reference/master/index.html>
L<Ado::Plugin>, L<Ado::Manual>.

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
