package Ado::Sessions::Database;
use Mojo::Base 'Ado::Sessions';
use Mojo::JSON;
use Mojo::Util;

use Data::Dumper;
use Ado::Model::Sessions;

sub load {
    my ($self, $c) = @_;

    my $id = $self->session_id($c) || '';

    $c->app->log->debug(ref($self) . "->load(), id:$id");

    my $session = {};
    if ($id) {
        my $adosession = Ado::Model::Sessions->find($id);
        if ($adosession->data) {
            return
              unless $session = Mojo::JSON->new->decode(b64_decode $adosession->sessiondata);
        }
    }

    # "expiration" value is inherited
    my $expiration = $session->{expiration} // $self->default_expiration;
    return if !(my $expires = delete $session->{expires}) && $expiration;
    return if defined $expires && $expires <= time;

    my $stash = $c->stash;
    return unless $stash->{'mojo.active_session'} = keys %$session;
    $stash->{'mojo.session'} = $session;
    $session->{flash} = delete $session->{new_flash} if $session->{new_flash};

    return;
}

sub store {
    my ($self, $c) = @_;


    # Make sure session was active
    my $stash = $c->stash;
    return unless my $session = $stash->{'mojo.session'};
    return unless keys %$session || $stash->{'mojo.active_session'};

    # Don't reset flash for static files
    my $old = delete $session->{flash};
    @{$session->{new_flash}}{keys %$old} = values %$old
      if $stash->{'mojo.static'};
    delete $session->{new_flash} unless keys %{$session->{new_flash}};

    # Generate "expires" value from "expiration" if necessary
    my $expiration = $session->{expiration} // $self->default_expiration;
    my $default = delete $session->{expires};
    $session->{expires} = $default || time + $expiration
      if $expiration || $default;


    my $id = $self->session_id($c) || $self->generate_id();
    my $options = {
        domain   => $self->cookie_domain,
        expires  => $session->{expires},
        httponly => 1,
        path     => $self->cookie_path,
        secure   => $self->secure
    };

    #once
    state $cookie_name = $self->cookie_name;
    $c->cookie($cookie_name, $id, $options);
    $c->res->headers('X-' . $cookie_name => $id);    #CORS

    my $value = b64_encode(Mojo::JSON->new->encode($session), '');
    my $adosession = Ado::Model::Sessions->find($id);
    if ($adosession->data) {
        $adosession->sessiondata($value)->update();
        return;
    }
    Ado::Model::Sessions->create(id => $id, tstamp => time(), sessiondata => $value);
    return;
}
1;


