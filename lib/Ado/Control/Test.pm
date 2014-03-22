package Ado::Control::Test;
use Mojo::Base 'Ado::Control';

sub authenticateduser { return $_[0]->render(text => 'hello authenticated ' . $_[0]->user->name) }
sub mark_down         { return $_[0]->render(text => $_[0]->markdown('* some text')) }

1;

=pod

=encoding utf8

=head1 NAME

Ado::Control::Test - a controller used for testing Ado.

=head1 DESCRIPTION

In this package we put actions which are used only for testing Ado functionality.

=head1 ACTIONS

=head2 authenticateduser 

Used to test  the L<Ado::Plugin::Auth/authenticated> condition.

=head2 mark_down

Used to test  L<Ado::Plugin::MarkdownRenderer> C<markdown> helper


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


