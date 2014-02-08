#t/plugin/markdown_renderer.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
eval "use Text::MultiMarkdown;";
plan skip_all => "Text::MultiMarkdown required for this test" if $@;


my $t = Test::Mojo->new('Ado');

#Plugins are loaded already.
can_ok('Ado::Plugin::MarkdownRenderer', 'md_to_html');


my $app = $t->app;


done_testing();
