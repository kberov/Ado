package Ado::Control::Test;
use Mojo::Base 'Ado::Control';

sub authenticateduser { return $_[0]->render(text => 'hello authenticated ' . $_[0]->user->name) }
sub mark_down         { return $_[0]->render(text => $_[0]->markdown('* some text')) }

sub l10n {
    $_[0]->debug('already set language:' . $_[0]->language);
    return $_[0]->render(text => $_[0]->l('hello', $_[0]->user->name));
}

sub bgl10n {
    $_[0]->language('bg');
    $_[0]->debug('set language inside action:' . $_[0]->language);
    return $_[0]->render(text => $_[0]->l('hello', $_[0]->user->name));
}
*index = \&l10n;
1;

=pod

=encoding utf8

=head1 NAME

Ado::Control::Test - a controller used for testing Ado.

=head1 DESCRIPTION

In this package we put actions which are used only for testing Ado functionality.
Below is the list of defined actions.


=head2 authenticateduser 

Used to test  the L<Ado::Plugin::Auth/authenticated> condition.

=head2 mark_down

Used to test theC<markdown> helper defined in L<Ado::Plugin::MarkdownRenderer/markdown>. 

=head2 l10n

Used to test the C<l> controller helper L<Ado::Plugin::I18n/l>.

=head2 bgl10n

Used to test the C<language> helper L<Ado::Plugin::I18n/language>.

=head2 index

Alias for C<l10n> action.

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


