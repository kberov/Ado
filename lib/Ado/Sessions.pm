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

    return $c->param($cookie_name)
      || $c->cookie($cookie_name);
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

sub load {
    my ($self, $c, $session) = @_;

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

    my $value = Mojo::Util::b64_encode(Mojo::JSON->new->encode($session), '');

    return ($id, $value);
}

1;

=pod

=encoding UTF-8

=head1 NAME

Ado::Sessions - A factory for HTTP Sessions in Ado

=head1 DESCRIPTION

Ado::Sessions chooses the desired type of sessions and loads it.

=head1 SYNOPSIS

  #in ado.conf
  session => {
    type => 'database',
    options => {
        cookie_name        => 'ado',
        default_expiration => 86400,
    }         
  }

=head2 cookie_domain

Cookie domain accessor

=head2 cookie_name

Cookie name accessor

=head2 cookie_path

Cookie path accessor

=head2 default_expiration

Cookie default expiration accessor

=head2 generate_id

Session id generator

=head2 get_instance

Factory method for creating Ado session instance

=head2 load

Shares common logic and derived class should call

=head2 secure

Cookie is secure, flag

=head2 store

Shares common logic and derived class should call

=head2 session_id

Retrieves the session id from a parameter or cookie defaulting to L<cookie_name>. 
The C<cookie_name> can be set in C<ado.conf> section C<session>.

  my $id = $self->session_id($c);


=head1 SEE ALSO

L<Mojolicious::Sessions>, L<Ado::Sessions::File>, L<Ado::Sessions::Database>,
L<Using CORS|http://www.html5rocks.com/en/tutorials/cors/>

=cut


