package Ado::Sessions;
use Mojo::Base -base;

use Carp;
use Ado::Sessions::Db;
use Ado::Sessions::File;

has cookie_name => 'adosessionid';

sub generate_id {
    Mojo::Util->sha1_hex( rand() . $$ . {} . time );
}

sub session_id_from {
    my ( $self, $c ) = @_;
    return $c->param( $self->cookie_name )
      or $c->cookie( $self->cookie_name );
}

sub getInstance {
    my $of = shift;

    Carp::confess('Method requires single string argument: file, db, mojo')
      unless $of;

    return Ado::Sessions::File->new   if lc $of eq 'file';
    return Ado::Sessions::Db->new     if lc $of eq 'db';
    return Mojolicious::Sessions->new if lc $of eq 'mojo';

    Carp::confess('Method requires single string argument: file, db, mojo');
}

1;

