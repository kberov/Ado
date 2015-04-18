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
$config->{md_reuse_produced_html} = 0;
my $static_file = catfile($config->{md_articles_root}, 'hello.html');
unlink($static_file);

#$app->dumper($app->config('Ado::Plugin::MarkdownRenderer'));
$t->get_ok('/articles/hello.html')->status_is(200)
  ->text_like('h1' => qr'Ползата от историята');

ok(!-e $static_file, 'file /articles/hello.html is not created');
$t->get_ok('/articles/hello.html')->status_is(200)
  ->text_like('h1' => qr'Ползата от историята');


done_testing();

