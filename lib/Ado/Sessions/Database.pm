package Ado::Sessions::Database;
use Mojo::Base 'Ado::Sessions';
use Mojo::JSON;
use Mojo::Util qw(b64_decode b64_encode);
use Ado::Model::Sessions;

sub load {
    my ($self, $c) = @_;

    my $session = {};
    my $id = $self->session_id($c) || '';

    if ($id) {
        my $adosession = Ado::Model::Sessions->find($id);
        if ($adosession->data) {
            return
              unless $session = Mojo::JSON->new->decode(b64_decode $adosession->sessiondata);
        }
    }

    return $self->prepare_load($c, $session);
}

sub store {
    my ($self, $c) = @_;

    my ($id, $session) = $self->prepare_store($c);
    my $value = Mojo::Util::b64_encode(Mojo::JSON->new->encode($session), '');

    my $adosession = Ado::Model::Sessions->find($id);
    if ($adosession->data) {
        $adosession->sessiondata($value)->update();
        return;
    }
    Ado::Model::Sessions->create(id => $id, tstamp => time(), sessiondata => $value);

    return;
}

1;

=pod

=encoding UTF-8

=head1 NAME

Ado::Sessions::Database - manage sessions stored in the database

=head1 DESCRIPTION

L<Ado::Sessions::Database> manages sessions for
L<Ado>. All data gets serialized with L<Mojo::JSON> and stored
C<Base64> encoded in the database. A cookie or a request parameter can
be used to share the session id between the server and the user agents.

=head1 METHODS

=head2 load

Load session data from database.

=head2 store

Save session data in database.

=head1 SEE ALSO

L<Mojolicious::Sessions>, L<Ado::Sessions::File>

=cut
