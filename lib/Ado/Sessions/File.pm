package Ado::Sessions::File;

use Mojo::Base 'Ado::Sessions';
use Mojo::Util qw(slurp spurt);

use File::Temp;

sub dstdir {
    return $ENV{TMP} || $ENV{TEMP} || $ENV{TMPDIR} || '/tmp';
}

sub dstfile {
    my ($self, $id) = @_;
    return $self->dstdir . '/ado.' . $id;
}

sub absfile {
    my ($self, $id) = @_;
    return $self->dstdir . '/' . $self->dstfile($id);
}

sub load {
    my ($self, $c) = @_;
    $c->app->log->debug(ref($self) . "->load()");
    return;
}

sub store {
    my ($self, $c) = @_;
    $c->app->log->debug(ref($self) . "->store()");

    my $id   = $self->generate_id();
    my $file = $self->absfile($id);

    $c->app->log->debug(ref($self) . "->store($file)");
    $c->cookie($self->cookie_name => $id);
    return;
}

# TODO
sub cleanup {

}

1;

=pod

=encoding UTF-8

=head1 NAME

Ado::Sessions::File - manage sessions stored in the files

=head1 DESCRIPTION

L<Ado::Sessions::File> manages sessions for
L<Ado>. All data gets serialized with L<Mojo::JSON> and stored
C<Base64> encoded in the file. A cookie or a request parameter can be used to 
share the session id between the server and the user agents.

=head1 METHODS

=head2 absfile

Compose absolute path to session data file.

=head2 cleanup

This method is a garbage collector. Cleans up expired session files.

=head2 dstdir

Path where to store session data files.

=head2 dstfile

File name of the session data file.

=head2 load

Load session data from file.

=head2 store

Store session data in file.

=cut

