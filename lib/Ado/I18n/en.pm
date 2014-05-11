package Ado::I18n::en;
use Mojo::Base 'Ado::I18n';
use I18N::LangTags::List;
our %Lexicon = (    ##no critic(ProhibitPackageVars)
    hello             => 'Hello [_1],',
    Logout            => 'Sign out',
    login_name        => 'User',
    login_password    => 'Password',
    login_field_error => 'Please enter a valid value for the field "[_1]"!',
    first_name        => 'First Name',
    last_name         => 'Last Name',
    title             => 'Title/Name',
    tags              => 'Tags',
    time_created      => 'Created on',
    tstamp            => 'Changed on',
    body              => 'Content (body)',
    invisible         => 'Invisible',
    language          => 'Language',
    group_id          => 'Group',
    bg                => I18N::LangTags::List::name('bg'),
    en                => I18N::LangTags::List::name('en'),
    ru                => I18N::LangTags::List::name('ru'),
    de                => I18N::LangTags::List::name('de'),

    ASC        => 'Ascending',
    DESC       => 'Descending',
    created_by => 'Created by',
    disabled   => 'Locked',
);

1;

=pod

=encoding utf8

=head1 NAME

Ado::I18n::en - lexicon for English

=cut
