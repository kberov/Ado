#t/plugin/i18n.t
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;
use_ok('Ado');
use_ok('Ado::I18n');
use_ok('Ado::I18n::en');
use_ok('Ado::I18n::bg');
use_ok('Ado::Plugin::I18n');

#test default config
my $ado    = Ado->new();
my $i18n   = Ado::Plugin::I18n->new->register($ado);
my $config = {
    default_language      => 'en',
    languages             => ['en', 'de', 'bg'],
    language_from_route   => 1,
    language_from_host    => 1,
    language_from_param   => 1,
    language_from_cookie  => 1,
    language_from_headers => 1,
    language_param        => 'language',
    namespace             => 'Ado::I18n',
};
my $l = join '|', @{$$config{languages}};
my $routes = [

    {   route  => '/:language',
        params => {$$config{language_param} => qr/(?:$l)/},
        via    => [qw(GET OPTIONS)],

        #Ado::Control::Default::index()
        to => 'default#index',
    },
    {   route  => '/:language/:controller',
        via    => [qw(GET OPTIONS)],
        params => {$$config{language_param} => qr/(?:$l)/},
        to     => {

            #Ado::Control::Default
            controller => 'Default',
            action     => 'index'
        }
    },
    {   route  => '/:language/:controller/:action',
        via    => [qw(GET POST OPTIONS)],
        params => {$$config{language_param} => qr/(?:$l)/},
        to     => {

            #Ado::Control::Default
            controller => 'Default',
            action     => 'index'
        }
    },
    {   route  => '/:language/:controller/:action/:id',
        via    => [qw(GET PUT DELETE OPTIONS)],
        params => {$$config{language_param} => qr/($l)/},
        to     => {

            #Ado::Control::Default
            controller => 'Default',
            action     => 'form'
        }
    },
];
$$config{routes} = $routes;
is_deeply($i18n->config, $config, 'default config ok');

delete ${Ado::}{dbix};    #shut up redefine
$ado = Ado->new();
for (keys %$config) {
    $config->{$_} = 1 if $_ =~ /language_from/;
}
$$config{routes} = [];
$i18n = Ado::Plugin::I18n->new->register($ado, $config);
is_deeply($i18n->config, $config, 'custom config ok');


done_testing;
