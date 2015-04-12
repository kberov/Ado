package Ado::Control::Articles;
use Mojo::Base 'Ado::Control';
File::Spec::Functions->import(qw(catfile));
Mojo::ByteStream->import(qw(b));

sub show {
    my ($c) = @_;
    state $root   = $c->app->home->rel_dir('public/articles');
    state $config = $c->app->config('Ado::Plugin::MarkdownRenderer');
    my ($html_content, $html_file) = ('', $c->stash->{html_file});
    my $md_file = $html_file;
    $md_file =~ s/\.html/.md/;    #switch file extension
    my $file_path = catfile($root, $md_file);

    if (-s $file_path) {
        my $markdown = b($file_path)->slurp->decode->to_string;
        $html_content = $c->render_to_string('articles/show',
            html => $c->markdown($markdown, {self_url => $c->url_for->to_string}));

        if ($config->{md_reuse_produced_html}) {

            #save file to disk for later requests and redirect to the generated static file
            b($html_content)->encode->spurt(catfile($root, $html_file));
            return $c->redirect_to($c->url_for('/articles/' . $html_file));
        }
        return $c->render(text => $html_content);
    }
    else {
        $c->res->code(404);

    }
}
1;
