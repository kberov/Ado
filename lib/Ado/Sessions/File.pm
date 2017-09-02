package Ado::Sessions::File;

use Mojo::Base 'Ado::Sessions';
use Mojo::Util qw(b64_decode b64_encode);
use File::Spec::Functions qw(tmpdir catfile);
use Mojo::File 'path';

has dstdir => sub {tmpdir};

sub dstfile {
    my ($self, $id) = @_;
    return 'ado.' . $id;
}

sub absfile {
    my ($self, $id) = @_;
    return catfile $self->dstdir, $self->dstfile($id);
}

sub load {
    my ($self, $c) = @_;

    my $session     = {};
    my $id          = $self->session_id($c) || '';
    my $cookie_file = $self->absfile($id);

    if ($id and -e $cookie_file) {
        my $sessiondata = path($cookie_file)->slurp();
        return
          unless $session = Mojo::JSON::j(b64_decode($sessiondata));
    }

    return $self->prepare_load($c, $session);
}

sub store {
    my ($self, $c) = @_;

    my ($id, $session) = $self->prepare_store($c);
    my $value = b64_encode(Mojo::JSON::encode_json($session), '');
    my $file = $self->absfile($id);
    path($file)->spurt($value);
    chmod(oct('0600'), $file);
    return;
}

# TODO
sub cleanup {

    # go to session dir
    # find all ado.* files
    # filter against file age where is older than session timeout
    # unlink all old files

    # Warning!
    # This action will slow down the application performance, so considering
    # any other GC, like cronjob or watchdog would be a better solution.
}

1;

=pod

=encoding UTF-8

=head1 NAME

Ado::Sessions::File - manage sessions stored in files

=head1 DESCRIPTION

L<Ado::Sessions::File> manages sessions for
L<Ado>. All data gets serialized with L<Mojo::JSON> and stored
C<Base64> encoded in a file. A cookie or a request parameter can be used to
share the session id between the server and the user agents.

=head1 ATTRIBUTES

L<Ado::Sessions::File> inherits all attributes from
L<Ado::Sessions> and implements the following new ones.

=head2 dstdir

Path where to store session data files.


=head1 METHODS

=head2 absfile

Compose absolute path to session data file.

=head2 cleanup

This method is a garbage collector. Cleans up expired session files.


=head2 dstfile

File name of the session data file.

=head2 load

Load session data from file.

=head2 store

Store session data in file.


=head1 SEE ALSO

L<Mojolicious::Sessions>, L<Ado::Sessions::Database>

=cut


