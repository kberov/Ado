package Ado::I18n;
use Mojo::Base 'Locale::Maketext';
our %Lexicon = (_AUTO => 1);    ##no critic(ProhibitPackageVars)

sub get_handle {
    my ($class, $language, $c, $config) = @_;
    state $loaded = {};

    my $self = $class->SUPER::get_handle($language, @{$$config{languages}});
    $self->_load_messages_from_db($c->dbix, $$config{default_language})
      unless $loaded->{$language};
    $Ado::Control::DEV_MODE && $c->debug('loaded language:' . ref($self));
    $loaded->{$language} = 1;
    return $self;
}

sub _load_messages_from_db {
    my ($self, $dbix, $default) = @_;
    my $SQL = <<'SQL';
SELECT d.msgid AS msgid,(
  CASE 
    WHEN cl.msgstr IS NULL OR cl.msgstr=''
    THEN d.msgstr
    ELSE cl.msgstr
  END) AS msgstr
-- default language
FROM (SELECT msgid, msgstr FROM i18n WHERE lang=?) d
-- current language
LEFT JOIN (SELECT msgid, msgstr FROM i18n WHERE lang=?) cl
ON (cl.msgid=d.msgid)
SQL

    #get messages from database
    my $lex = $dbix->query($SQL, $default, $self->language_tag)->map;
    {
        no strict 'refs';    ## no critic (ProhibitNoStrict)
        my $class_lex = ref($self) . '::Lexicon';
        %{$class_lex} = (%{$class_lex}, $lex);
    };
    return;
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::I18n - Languages' lexicons and handle namespace

=head1 DESCRIPTION

This class is used to instantiate the language handle in L<Ado>.

=head1 METHODS

This class inherits all methods from L<Locale::Maketext> and defines the
following ones.

=head2 get_handle

Constructor

  my $i18n = Ado::I18n->get_handle('bg', $c, $config);
  $i18n->maketext('hello',$user->name); # Здравей, Красимир Беров


=head1 SEE ALSO

L<Locale::Maketext>, L<Ado::Plugin::I18n>, L<Ado::Manual::Plugins>, 

=head1 SPONSORS

The original author

=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2014 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

