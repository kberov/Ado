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

#action to test language_menu
sub language_menu {
    my ($c) = @_;

    #small hack to use embedded template
    state $renderer = scalar push @{$c->app->renderer->classes}, __PACKAGE__;
    my $stash = $c->stash;

    $c->debug('$$stash{language_from}:' . $$stash{language_from});
    $$stash{language_from} ||= $c->param('from');
    $c->debug('$$stash{language_from}:' . $$stash{language_from});
    return;
}

# Test Ado::Model::Users->by_group_name
sub ingroup {
    my $c = shift;

    #get users from group with the same name as the user login_name
    my @users = Ado::Model::Users->by_group_name($c->user->login_name, $c->param('offset'),
        $c->param('limit'));
    return $c->render(json => [map { $_->data } @users]);

}
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

=head2 language_menu

Used to test the produced HTML by C<partials/language_menu.html.ep>.

=head2 index

Alias for C<l10n> action.

=head2 ingroup

Used to test the C<ingroup> condition and  L<Ado::Model::Users/by_group_name>.

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


__DATA__

@@ test/language_menu.html.ep
<!DOCTYPE html>
<html>
  <head><%= include 'partials/head'; %></head>
  <body>
<nav id="adobar" class="ui borderless small purple inverted fixed menu">
%= include 'partials/language_menu' 
</nav>
<main class="ui">
  <article class="ui main container">

  %= tag 'h1' => l('hello', user->name);
  </article>

</main>
</body>
</html>

