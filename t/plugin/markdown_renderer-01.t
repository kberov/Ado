use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
File::Spec::Functions->import(qw(catfile));

eval "use Text::MultiMarkdown;";
plan skip_all => "Text::MultiMarkdown required for this test" if $@;

my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

#test Ado::Control::Articles
my $config = $app->config('Ado::Plugin::MarkdownRenderer');

is($config->{md_reuse_produced_html}, 1);
my $static_file = $app->home->rel_file('public/articles/hello.html');
unlink($static_file);

#file is generated and the user is redirected to it.
$t->get_ok('/articles/hello.html')->status_is(302);
$t->get_ok('/articles/not_found.html')->status_is(404)->text_like('h1' => qr'Not Found');
ok(-e $static_file, 'file /articles/hello.html really exists');

#static file
$t->get_ok('/articles/hello.html')->status_is(200)
  ->text_like('h1' => qr'Ползата от историята');

#cached static file: Check If-Modified-Since
my $mtime = Mojo::Date->new(Mojo::Asset::File->new(path => $static_file)->mtime)->to_string;
$t->head_ok('/articles/hello.html' => {'If-Modified-Since' => $mtime})->status_is(304);

#test Ado::Control::Articles 2
$config->{md_reuse_produced_html} = 0;
$static_file = catfile($config->{md_articles_root}, 'hello.html');
unlink($static_file);

#$app->dumper($app->config('Ado::Plugin::MarkdownRenderer'));
$t->get_ok('/articles/hello.html')->status_is(200)
  ->text_like('h1' => qr'Ползата от историята');

ok(!-e $static_file, 'file /articles/hello.html is not created');
$t->get_ok('/articles/hello.html')->status_is(200)
  ->text_like('h1' => qr'Ползата от историята');


done_testing();

