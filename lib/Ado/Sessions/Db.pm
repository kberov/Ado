package Ado::Sessions::Db;
use Mojo::Base 'Ado::Sessions';
use Mojo::JSON;
use Mojo::Util;

use Data::Dumper;
use Ado::Model::Sessions;

sub load {
    my ( $self, $c ) = @_;

    $c->app->log->debug( ref($self) . "->load()" );

    my $id = $self->session_id_from($c);

    if ($id) {
        my $session = Ado::Model::Sessions->find($id);
        if ( $session->data ) {
            return Mojo::JSON->new->decode( $session->data->sessiondata );
        }
    }

    return;
}

sub store {
    my ( $self, $c ) = @_;

    my $stash = $c->stash;
    my $id    = $self->session_id_from($c);

    $c->app->log->debug( ref($self) . "->store->find($id)" );

    my $sess = Ado::Model::Sessions->find($id);
    if ( not $sess->data ) {
        $c->app->log->debug(
            "Session with id $id not found, will generate new one."
              . Dumper($sess) );
        $id = $self->generate_id($c);
        $c->app->log->debug("New session id is $id");
    }

    my $session = $stash->{'mojo.session'} || {};
    $sess->id($id)->sessiondata( Mojo::JSON->new->encode($session) )->save();

    $c->cookie( $self->cookie_name => $id );
    $c->app->log->debug( ref($self) . "->store(" . $id . ")" );
}

1;


