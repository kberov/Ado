package Ado::Sessions;
use Mojo::Base -base;
use Mojo::JSON;

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
      || '';
}

sub get_instance {
    my $config  = shift;
    my $options = $config->{session}{options} || {};
    my $type    = lc $config->{session}{type} || 'mojo';    #sane default

    if ($type eq 'mojo') {
        return Mojolicious::Sessions->new(%$options);
    }
    elsif ($type eq 'file') {
        require Ado::Sessions::File;
        return Ado::Sessions::File->new(%$options);
    }
    elsif ($type eq 'database') {
        require Ado::Sessions::Database;
        return Ado::Sessions::Database->new(%$options);
    }

    Carp::croak('Please provide valid session type:(mojo,file,database)');
    return;
}

sub prepare_load {
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

sub prepare_store {
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

    return ($id, $session);
}

1;

=pod

=encoding UTF-8

=head1 NAME

Ado::Sessions - A factory for HTTP Sessions in Ado

=head1 DESCRIPTION

Ado::Sessions chooses the desired type of session storage and loads it.

=head1 SYNOPSIS

  #in ado.conf
  session => {
    type => 'database',
    options => {
        cookie_name        => 'ado',
        default_expiration => 86400,
    }         
  }

  #In Ado.pm:
  has sessions => sub { Ado::Sessions::get_instance(shift->config) };


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

=head2 prepare_load

Shares common logic which is compatible with L<Mojolicious::Sessions>.
The storage implementation class should call this method after it loads
the session from the respective storage.

    $self->prepare_load($c, $session);

=head2 secure

Cookie is secure, flag

=head2 prepare_store

Shares common logic which is compatible with L<Mojolicious::Sessions>.
The storage implementation class should call this method before it stores
the session to the the respective storage.
Returns the session id and the session ready to be serialized
and base 64 encoded.

    my ($id, $session) = $self->prepare_store($c);

=head2 session_id

Retrieves the session id from a parameter or cookie defaulting to L<cookie_name>. 
The C<cookie_name> can be set in C<ado.conf> section C<session>.

  my $id = $self->session_id($c);


=head1 SEE ALSO

L<Mojolicious::Sessions>, L<Ado::Sessions::File>, L<Ado::Sessions::Database>,
L<Using CORS|http://www.html5rocks.com/en/tutorials/cors/>

=cut


