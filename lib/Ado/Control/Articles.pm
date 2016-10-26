package Ado::Control::Articles;
use Mojo::Base 'Ado::Control';
File::Spec::Functions->import(qw(catfile splitpath catdir));
Mojo::ByteStream->import(qw(b));
use File::Path qw(make_path);

sub show {
    my ($c) = @_;
    state $config = $c->app->config('Ado::Plugin::MarkdownRenderer');
    state $root   = $config->{md_articles_root};
    my ($html_content, $html_file) = ('', $c->stash->{html_file});
    my $md_file = $html_file;
    $md_file =~ s/(\.[^\.]+)?$/$config->{md_file_sufixes}[0]/;    #switch file extension
    my $file_path = catfile($root, $md_file);

    if (-s $file_path) {
        my $markdown = b($file_path)->slurp->decode->to_string;

        if ($config->{md_reuse_produced_html}) {
            $html_content = $c->render_to_string('articles/show',
                html => $c->markdown($markdown, {self_url => $c->url_for->to_string}));

            #save file to disk for later requests and redirect to the generated static file
            my $html_path = catfile($root, $html_file);
            make_path(catdir((splitpath($html_path))[0 .. -2]));
            b($html_content)->encode->spurt($html_path);
            $c->redirect_to($c->url_for('/articles/' . $html_file));
            return;
        }
        else {
            $c->render(html => $c->markdown($markdown, {self_url => $c->url_for->to_string}));
            return;
        }
    }
    else {
        $c->res->code(404);
        return;
    }
    Carp::croak('Should never get here!');
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Control::Articles - display markdown documents.

=head1 SYNOPSIS

  #in your browser go to
  http://your-host/articles


=head1 DESCRIPTION

Ado::Control::Articles is a controller that generates full static HTML
documents for markdown files found in the folder specified in
C<md_articles_root> in C<etc/plugins/markdown_renderer.$mode.conf>. It allows
you to have a simple static blog on Ado in no time, i.e. install Ado and you
have a personal blog.

=head1 METHODS/ACTIONS

L<Ado::Control::Articles> inherits all the methods from
L<Ado::Control> and defines the following.

=head2 show

Renders the file found in C<$c-E<gt>stash('html_file')> but with extension
C<.md>. If C<$config-E<gt>{md_reuse_produced_html}> is set, the produced html
file is saved in C<$config-E<gt>{md_articles_root}>. This way the next time
the resource is requested L<Mojolicious> renders the produced static file.

=head1 SEE ALSO

L<Ado::Control::Doc>, L<Ado::Plugin::MarkdownRenderer>,
L<Text::MultiMarkdown>, L<http://fletcherpenney.net/multimarkdown/>,
L<MultiMarkdown Guide|https://rawgit.com/fletcher/human-markdown-reference/master/index.html>
L<Ado::Plugin>, L<Ado::Manual>.

=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=cut

