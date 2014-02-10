package Ado::Control::Doc;
use Mojo::Base 'Ado::Control';

#Renders the page found in md_file
sub show {
    my $c = shift;
    my $document = $c->md_to_html() || return;
    $document = Mojo::DOM->new($document);
    my $title = $document->find('h1,h2,h3')->[0];

    if (not $title) {
        $title = 'Няма Заглавие!';
        $c->title($title);
        $document->at('article')->prepend_content(qq|<h1 class="error">$title</h1>|);
    }
    else {
        $c->title($title->text);
    }
    $c->stash(document => $document->to_string);

    return $c->render();
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Control::Doc - The controller for the end-user documentation 

=head1 SYNOPSIS

  #in your browser go to
  http://your-host/help

=head1 DESCRIPTION

This is a minimal controller to display and browse end-user documentation
written in markdown format.

=head1 METHODS/ACTIONS

L<Ado::Control::Doc> inherits all the methods from 
L<Ado::Control> and defines the following ones.

=head2 show

Renders the page found in C<$c-E<gt>stash('md_file');>.

=head1 SPONSORS

The original author

Become a sponsor and help make L<Ado> the ERP for the enterprise!

=head1 SEE ALSO

L<Ado::Plugin::MarkdownRenderer>,
L<Ado::Control>, L<Mojolicious::Controller>, 
L<Mojolicious::Guides::Growing/Model_View_Controller>,
L<Mojolicious::Guides::Growing/Controller_class>


=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut
