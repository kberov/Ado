package Ado::Command::adduser;
use Mojo::Base 'Ado::Command';
use Getopt::Long qw(GetOptionsFromArray);
use Time::Piece qw();
use Time::Seconds;
has description => "Adds a user to an Ado application.\n";
has usage       => <<"USAGE";
USAGE:

# Minimal required options to add a user
$0 adduser --login_name USERNAME --email user\@example.com \
    --first_name John --last_name Smith 

# Add a user to an additional group
$0 adduser --login_name USERNAME --ingroup GROUPNAME

# Change password / disable a user
$0 adduser --login_name USERNAME --ingroup GROUPNAME --disabled \
--login_password !@#\$\%^&

See perldoc Ado::Command::adduser for full set of options.

USAGE

#define some defaults
has args => sub {
    my $t = time;
    {   changed_by => 1,
        created_by => 1,
        disabled   => 1,

        #TODO: add funcionality for notifying users on account expiration
        #TODO: document this
        stop_date      => $t + ONE_YEAR,             #account expires after one year
        start_date     => $t,
        login_password => rand($t) . $$ . {} . $t,
    };
};

sub init {
    my ($self, @args) = @_;
    $self->SUPER::init();
    unless (@args) { Carp::croak($self->usage); }
    my $args = $self->args;
    my $ret  = GetOptionsFromArray(
        \@args,
        'u|login_name=s'     => \$args->{login_name},
        'p|login_password=s' => \$args->{login_password},
        'e|email=s'          => \$args->{email},
        'g|ingroup=s'        => \$args->{ingroup},
        'd|disabled:i'       => \$args->{disabled},
        'f|first_name=s'     => \$args->{first_name},
        'l|last_name=s'      => \$args->{last_name},
        'start_date=s'       => sub {
            $args->{start_date} =
              $_[1] ? Time::Piece->strptime('%Y-%m-%d', $_[1])->epoch : time;
        },
    );
    $args->{login_password} = Mojo::Util::sha1_hex($args->{login_name} . $args->{login_password});
    unless ($args->{ingroup}) {
        say($self->usage)
          unless ($args->{first_name}
            and $args->{last_name}
            and $args->{login_name}
            and $args->{email});
    }
    $self->app->log->debug('$self->args: ' . $self->app->dumper($self->args));
    return $ret;
}


#default action
sub adduser {
    my $self = shift;
    my $args = $self->args;
    my ($group, $user, $ingroup);
    if (($group = Ado::Model::Groups->by_name($args->{login_name}))->id) {
        $self->app->log->debug('$group:', $self->app->dumper($group));

        #if we have such group, we have the user or we do not want to give a user
        #the privileges of a shared group
        say "'$args->{login_name}' is already taken!";
    }
    else {
        $user = Ado::Model::Users->add($args) unless $group->id;
        return unless $user;
    }
    if ($user) {
        say "User '$args->{login_name}' was created with primary group '$args->{login_name}'.";
    }
    else {
        $user = Ado::Model::Users->by_login_name($args->{login_name});
    }

    return unless $args->{ingroup};
    if (not $user->ingroup($args->{ingroup})) {
        if ($ingroup = $user->add_to_group($args)) {
            say "User '$args->{login_name}' was added to group '$args->{ingroup}'.";
        }
    }
    else {
        say "User '$args->{login_name}' is already in group '$args->{ingroup}'.";
    }
    return 1;
}


1;

=pod

=encoding utf8

=head1 NAME

Ado::Command::adduser - adduser command

=head1 SYNOPSIS

  
  use Ado::Command::adduser;
  Ado::Command::adduser->run('--login_name'=>'test1',...);

=head1 DESCRIPTION

L<Ado::Command::adduser> adds a user to an L<Ado> application.
It is a facade for L<Ado::Model::Users>.
This is a core L<Ado> command, that means it is always enabled and its code a good
example for learning to build new L<Ado> commands, you're welcome to fork it.

=head1 ATTRIBUTES

L<Ado::Command::adduser> inherits all attributes from
L<Ado::Command> and implements the following new ones.

=head2 args

  $self->args(login_name=>'peter','ingroup'=>'facebook');
  my $args = $self->args;

Default arguments for creating a user.


=head2 description

  my $description = $a->description;
  $a              = $a->description('Foo!');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $a->usage;
  $a        = $a->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 OPTIONS

On the commandline C<ado adduser> accepts the following options:

    'u|login_name=s'     #username (mandatory)
    'p|login_password=s' #the user password (optional, random is generated)
    'e|email=s'          #user email (mandatory)
    'g|ingroup=s'        #additional group, can be used for existing users too
    'd|disabled:i'       #is user disabled? (1 by default)
    'f|first_name=s'     #user's first name (mandatory)
    'l|last_name=s'      #user's last name (mandatory)
    'start_date=s'       #format: %Y-%m-%d (optional, today by default)

=head1 METHODS

L<Ado::Command::adduser> inherits all methods from
L<Ado::Command> and implements the following new ones.

=head2 init

Calls the default parent L<Ado::Command/init> and parses the arguments
passed on the command-line. Returns true on success. 
Croaks with L</usage> message on failure.


=head2 adduser

The default and only action this command implements.
Makes logical checks for existing user and group and calls 
L<Ado::Model::Users/adduser> and L<Ado::Model::Users/add_to_group>
depending on parsed arguments.
See L<Ado::Command/run>.

=head1 SEE ALSO

L<Ado::Model::Users>,
L<Ado::Command> L<Ado::Manual>, L<Mojolicious::Command>, 
L<Mojolicious>, L<Mojolicious::Guides>.

=cut

