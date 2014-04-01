package Ado::Command::adduser;
use Mojo::Base 'Ado::Command';
use Getopt::Long qw(GetOptionsFromArray);
use Time::Piece qw();

has description => "Adds a user to an Ado application.\n";
has usage       => <<"USAGE";
usage: 
#All defaults
$0 adduser --login_name USERNAME
#Add a user to an additional group
$0 adduser --ingroup GROUPNAME

$0 adduser --login_name USERNAME --ingroup GROUPNAME --disabled \
--login_password !@#\$\%^&

See perldoc Ado::Command::adduser for full set of options.

USAGE

sub init {
    my ($self, @args) = @_;
    $self->SUPER::init();
    unless (@args) { Carp::croak($self->usage); return; }
    GetOptionsFromArray(
        \@args,
        'u|login_name=s'     => \$self->args->{login_name},
        'p|login_password=s' => \$self->args->{login_password},
        'g|ingroup=s'        => \$self->args->{ingroup},
        'changed_by=i'       => sub { $self->args->{changed_by} = $_[1] || 1 },
        'd|disabled:i'       => sub { $self->args->{disabled} = $_[1] || 0 },
        'tstamp:i'           => time(),
        'stop_date=s'        => sub {
            $self->args->{stop_date} =
              $_[1] ? Time::Piece->strptime('%Y-%m-%d', $_[1])->epoch : 0;
        },
        'start_date=s' => sub {
            $self->args->{start_date} =
              $_[1] ? Time::Piece->strptime('%Y-%m-%d', $_[1])->epoch : time();
        },
        'ingroup=s' => \$self->args->{ingroup},
    );

    #Carp::carp $self->app->dumper($self->args);
    return 1;
}


#default action
sub adduser {
    my $user = Ado::Model::Users->adduser(shift->args);
    return;
}


1;

=pod

=encoding utf8

=head1 NAME

Ado::Command::adduser - adduser command

=head1 SYNOPSIS

  use Ado::Command::adduser;

  my $a = Ado::Command::adduser->new;
  $a->run(login_name=>'test');

=head1 DESCRIPTION

L<Ado::Command::adduser> adds a user to an L<Ado> application.

This is a core command, that means it is always enabled and its code a good
example for learning to build new commands, you're welcome to fork it.

=head1 ATTRIBUTES

L<Ado::Command::adduser> inherits all attributes from
L<Ado::Command> and implements the following new ones.

=head2 description

  my $description = $a->description;
  $a              = $a->description('Foo!');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $a->usage;
  $a        = $a->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Ado::Command::version> inherits all methods from
L<Ado::Command> and implements the following new ones.

=head2 init

Default initialization.


=head2 adduser

The default and only action this command implements.
See L<Ado::Command/run>.

=head1 SEE ALSO

L<Ado::Command> L<Ado::Manual>, L<Mojolicious::Command>, 
L<Mojolicious>, L<Mojolicious::Guides>.

=cut

