package Ado::Sessions::File;

use Mojo::Base 'Ado::Sessions';
use Mojo::Util qw(slurp spurt);

use File::Temp;

sub dstdir {
    $ENV{TMP} || $ENV{TEMP} || $ENV{TMPDIR} || '/tmp';
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
}

sub store {
    my ($self, $c) = @_;
    $c->app->log->debug(ref($self) . "->store()");

    my $id   = $self->generate_id();
    my $file = $self->absfile($id);

    $c->app->log->debug(ref($self) . "->store($file)");
    $c->cookie($self->cookie_name => $id);
}

# TODO
sub cleanup {

}

1;

