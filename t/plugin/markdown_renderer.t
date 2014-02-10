#t/plugin/markdown_renderer.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use File::Find;
eval "use Text::MultiMarkdown;";
plan skip_all => "Text::MultiMarkdown required for this test" if $@;


my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.
my $class = 'Ado::Plugin::MarkdownRenderer';
can_ok($class, 'md_to_html');
can_ok($class, 'config');
my $app     = $t->app;
my $plugin  = $class->new();
my $md_root = $plugin->config('md_root');
like($md_root, qr/doc$/, "ok md_root:$md_root");
like(
    $app->md_to_html('bg/no_title.md'),
    qr/^\<article\>.+?Няма\sЗаглавие/sx,
    'md_to_html works basicaly'
);

#cleanup any existing html
find(
    {   no_chdir => 1,
        wanted   => sub {
            ok(unlink($_), 'unlinked existing ' . $_)
              if $_ =~ /\.html$/;
          }
    },
    $md_root
);

#no_title
#help
$t->get_ok('/help/bg/toc.md')->status_is(200)->text_is('h1' => 'Съдържание')
  ->text_is('title' => 'Съдържание');

#help created already
$t->get_ok('/help/bg/toc.md')->status_is(200)->text_is('h1' => 'Съдържание')
  ->text_is('title' => 'Съдържание');

#no_title
$t->get_ok('/help/bg/no_title.md')->status_is(200)
  ->text_is('title' => 'Няма Заглавие!')
  ->text_is('h1'    => 'Няма Заглавие!');

#not found
$t->get_ok('/help/bg/alabala.md')->status_is(404)->text_like('p' => qr|/help/bg/alabala\.md|);

#test missing/default configuration
$plugin->{config} = {};
isa_ok($plugin->register($app) => $class);
is_deeply($plugin->config('md_file_sufixes') => ['.md'], 'default md_file_sufixes');
is($plugin->config('md_method') => 'markdown', 'default md_method');
is_deeply(
    $plugin->config('md_options') => {
        'base_url'      => '/doc',
        'use_wikilinks' => 1
    },
    'default md_options'
);
is($plugin->config('md_renderer') => 'Text::MultiMarkdown', 'default md_renderer');
like($md_root, qr/\/public\/doc$/, "ok md_root:$md_root");

#cleanup any created html during the tests
find(
    {   no_chdir => 1,
        wanted   => sub {
            ok(unlink($_), 'unlinked created ' . $_)
              if $_ =~ /\.html$/;
          }
    },
    $app->home->rel_dir('public/doc/bg')
);


done_testing();
