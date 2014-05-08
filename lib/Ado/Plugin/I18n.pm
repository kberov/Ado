package Ado::Plugin::I18n;
use Mojo::Base 'Ado::Plugin';
use I18N::LangTags qw(implicate_supers);
use I18N::LangTags::Detect;
use List::Util qw(first);
use Time::Seconds;
has routes => sub {
    [
#Any language prefixed front-end controllers
        {   route  => '/:language/:controller',
            via    => [qw(GET OPTIONS)],
            params => {language => [$_[0]->config('languages')]},
            to     => {

                #Ado::Control::Default
                controller => 'Default',
                action     => 'index'
            }
        },
        {   route  => '/:language/:controller/:action',
            via    => [qw(GET POST OPTIONS)],
            params => {language => [$_[0]->config('languages')]},
            to     => {

                #Ado::Control::Default
                controller => 'Default',
                action     => 'index'
            }
        },
        {   route  => '/:language/:controller/:action/:id',
            via    => [qw(GET PUT DELETE OPTIONS)],
            params => {language => [$_[0]->config('languages')]},
            to     => {

                #Ado::Control::Default
                controller => 'Default',
                action     => 'form'
            }
        },
    ];
};

sub register {
    my ($self, $app, $config) = @_;
    $self->app($app);    #!Needed in $self->config!

    #Merge passed configuration (usually from etc/ado.conf) with configuration
    #from  etc/plugins/markdown_renderer.conf
    $config = $self->{config} = {%{$self->config}, %{$config ? $config : {}}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($config));

    #Make sure we have all we need from config files.
    $config->{default_language} ||= 'en';

    #Supported languages by this system
    $config->{languages} ||= ['en', 'bg'];

    #Try to get language from these places in the order below
    $config->{language_from_param}   ||= 1;
    $config->{language_from_host}    ||= 1;
    $config->{language_from_url}     ||= 1;
    $config->{language_from_cookie}  ||= 1;
    $config->{language_from_headers} ||= 1;
    $config->{language_param}        ||= 'language';

    #Allow other namespaces too
    $config->{namespace} ||= 'Ado::I18n';

    #eval "require $config->{namespace};";
    my $e = Mojo::Loader->new->load($config->{namespace});
    warn qq{Loading "$config->{namespace}" failed: $e} if $e;

    #Add helpers
    $app->helper(language => sub { &_language($config, @_) });
    $app->helper(l        => \&_maketext);
    $app->helper(maketext => \&_maketext);

    #default routes including language tag.
    $app->load_routes($self->routes);
    $app->load_routes($config->{routes}) if (@{$config->{routes} // []});

    # Add hook
    $app->hook(before_routes => sub { _language($config, shift) });
    return $self;
}

#sets *once* and/or returns the current language - a controller property
sub _language {
    my ($config, $c, $language) = @_;

    #already set? language()
    $c->{language} && return $c->{language};
    my $language_param = $config->{language_param};

    #language('fr')
    if ($language) {
        $c->{language} = $language;
    }

    #?language=de
    elsif ($$config{language_from_param}) {
        $c->{language} = $c->param($language_param);
    }

    #bg.example.com
    if (!$c->{language} && $config->{language_from_host}) {
        ($c->{language}) = $c->req->headers->host =~ /^($_)\./;
    }

    #example.com/cz/foo/bar
    if (  !$c->{language}
        && $config->{language_from_url}
        && ($language = $c->req->url->path->parts->[0]))
    {
        $c->{language} = $language;
    }
    if (  !$c->{language}
        && $config->{language_from_cookie}
        && ($language = $c->cookie($language_param)))
    {
        $c->cookie($language_param => $language, {expires => time + ONE_MONTH});
        $c->{language} = $language;
    }

    #Accept-Language:"bg,fr;q=0.8,en-us;q=0.5,en;q=0.3"
    elsif (!$c->{language} && $config->{language_from_headers}) {
        my @languages =
          I18N::LangTags::implicate_supers(
            I18N::LangTags::Detect->http_accept_langs($c->req->headers->accept_language));
        foreach my $language (@languages) {
            $c->{language} = first { $_ =~ /$language/ } @{$config->{languages}};
            last if $c->{language};
        }
    }

    #default
    $c->{language} = $config->{default_language} unless $c->{language};
    $c->{i18n} = $config->{namespace}->get_handle($c->{language}, @{$config->{languages}});
    return $c->{language};
}

sub _maketext {
    my $c   = shift;
    my $key = shift;
    return $key unless my $handle = $c->{i18n};
    return $handle->maketext($key, @_);
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Plugin::I18n - Internationalization and localization for Ado



=cut
