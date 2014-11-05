package Ado::I18n::de;
use Mojo::Base 'Ado::I18n';
use I18N::LangTags::List;
our %Lexicon = (    ##no critic(ProhibitPackageVars)
    hello             => 'Hallo [_1],',
    Logout            => 'Ausloggen',
    login_name        => 'Benutzer',
    login_password    => 'Passwort',
    login_field_error => 'Bitte gültigen Wert in Feld "[_1]" eintragen!',
    first_name        => 'Vorname',
    last_name         => 'Nachname',
    title             => 'Titel/Name',
    tags              => 'Tags',
    time_created      => 'Angelegt am',
    tstamp            => 'Verändert am',
    body              => 'Inhalt (body)',
    invisible         => 'Versteckt',
    language          => 'Sprache',
    group_id          => 'Gruppe',
    bg                => I18N::LangTags::List::name('bg'),
    en                => I18N::LangTags::List::name('en'),
    ru                => I18N::LangTags::List::name('ru'),
    de                => I18N::LangTags::List::name('de'),

    ASC        => 'Aufsteigend',
    DESC       => 'Absteigend',
    created_by => 'Erstellt von',
    disabled   => 'Gesperrt',
);

1;

=pod

=encoding utf8

=head1 NAME

Ado::I18n::de - lexicon for German language

=cut
