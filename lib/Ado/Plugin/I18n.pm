package Ado::Plugin::MarkdownRenderer;
use Mojo::Base 'Ado::Plugin';
use I18N::LangTags;
use I18N::LangTags::Detect;

sub register {
    my ($self, $app, $config) = @_;
    $self->app($app);    #!Needed in $self->config!

    #Merge passed configuration (usually from etc/ado.conf) with configuration
    #from  etc/plugins/markdown_renderer.conf
    $config = $self->{config} = {%{$self->config}, %{$config ? $config : {}}};
    $app->log->debug('Plugin ' . $self->name . ' configuration:' . $app->dumper($config));

    #Make sure we have all we need from config files.
    $config->{default_language} ||= 'i_default';

    #Try to get language from these places in the order below
    $config->{language_from_host}    ||= 1;
    $config->{language_from_url}     ||= 1;
    $config->{language_from_cookies} ||= 1;
    $config->{language_from_headers} ||= 1;

    # Add helpers
    $app->helper(language => \&_language);
    $app->helper(loc      => \&_maketext);

    $app->load_routes($config->{routes}) if (@{$config->{routes}});
    return $self;
}

#sets or returns the current language
sub _language {
    my ($c, $config, $language) = @_;
    $c->stash(language => $language) && return $c->{stash}{language} if $language;


}


1;

=pod

=encoding utf8

=head1 NAME

Ado::Plugin::I18n -  Internationalization Plugin for Ado



=cut
