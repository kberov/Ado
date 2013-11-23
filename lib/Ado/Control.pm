package Ado::Control;
use Mojo::Base 'Mojolicious::Controller';

sub config {
    my ($c, $key) = @_;
    state $app = $c->app;
    return $app->config(ref $c)->{$key} if $key;
    return $app->config(ref $c);
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Control - The base class for all controllers!

=head1 SYNOPSIS

It must be inherited by all controlers.
Put code here only to be shared by it's subclasses or used in hooks.

  package Ado::Control::Hello;
  use Mojo::Base 'Ado::Control';

=head1 ATTRIBUTES

=head1 SUBROUTINES/METHODS

Methods shared among subclasses and in hooks

=head2 debug

A shortcut to:

  $c->app->log->debug(@_);

=head2 config

Overwrites the default helper L<Mojolicious::Plugin::DefaultHelpers/config>
which is actually an alias for L<Mojo/config>.
Returns configuration specific to the I<current controller> package only.

  #in Ado::Control::List or Ado::Control::Foo or...
  state $conf = $c->config();
  ...

To access the application configuration use C<$c-E<gt>app-E<gt>config('key')>.

=head1 SEE ALSO

L<Mojolicious::Controller>, L<Ado::Manual::Controllers>


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

