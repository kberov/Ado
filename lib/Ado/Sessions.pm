package Ado::Sessions;
use Mojo::Base -base;
use Mojo::JSON;
use Mojo::Util qw(b64_decode b64_encode);

has [qw(cookie_domain secure)];
has cookie_name        => 'ado';
has cookie_path        => '/';
has default_expiration => 3600;

sub generate_id {
    return Mojo::Util::sha1_hex(rand() . $$ . {} . time);
}

sub session_id {
    my ($self, $c) = @_;

    #once
    state $cookie_name = $self->cookie_name;

    return
         $c->param($cookie_name)
      || $c->cookie($cookie_name)
      || $c->req->headers->header('X-' . $cookie_name);
}

sub get_instance {
    my $config  = shift;
    my $options = $config->{session}{options} || {};
    my $type    = $config->{session}{type} || 'mojo';    #sane default
    return Mojolicious::Sessions->new(%$options) if lc $type eq 'mojo';
    return require Ado::Sessions::File && Ado::Sessions::File->new(%$options)
      if lc $type eq 'file';
    return require Ado::Sessions::Database && Ado::Sessions::Database->new(%$options)
      if lc $type eq 'database';
    return Carp::croak('Please provide valid session type:(mojo,file,database)');
}

1;

