#t/plugin/i18n.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

use_ok('Ado::I18n');
use_ok('Ado::I18n::en');
use_ok('Ado::I18n::bg');
use_ok('Ado::Plugin::I18n');

done_testing;
