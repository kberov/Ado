package Ado::Model::Users;    #A table/row class
use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(Ado::Model);
use Carp;
sub is_base_class { return 0 }
my $TABLE_NAME = 'users';

sub TABLE       { return $TABLE_NAME }
sub PRIMARY_KEY { return 'id' }
my $COLUMNS = [
    'id',         'group_id',   'login_name', 'login_password',
    'first_name', 'last_name',  'email',      'description',
    'created_by', 'changed_by', 'tstamp',     'reg_date',
    'disabled',   'start_date', 'stop_date'
];

sub COLUMNS { return $COLUMNS }
my $ALIASES = {};

sub ALIASES { return $ALIASES }
my $CHECKS = {
    'changed_by' => {'allow' => qr/(?^x:^\d{1,}$)/},
    'disabled'   => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^\d{1,1}$)/,
        'default'  => '1'
    },
    'tstamp' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^\d{1,}$)/
    },
    'login_password' => {
        'required' => 1,
        'defined'  => 1,

        #result of Mojo::Util::sha1_hex($login_name.$login_password)
        'allow' => qr/^[A-Fa-f0-9]{40}$/x
    },
    'stop_date'   => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'description' => {
        'allow'   => qr/(?^x:^.{1,255}$)/,
        'default' => 'NULL'
    },
    'last_name' => {'allow' => qr/(?^x:^.{1,255}$)/},
    'email'     => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,255}$)/
    },
    'group_id' => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'reg_date' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^-?\d{1,}$)/
    },
    'start_date' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^-?\d{1,}$)/
    },
    'id'         => {'allow' => qr/(?^x:\d{1,}$)/},
    'login_name' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,100}$)/
    },
    'created_by' => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'first_name' => {'allow' => qr/(?^x:^.{1,255}$)/}
};

sub CHECKS { return $CHECKS }

__PACKAGE__->QUOTE_IDENTIFIERS(0);

#__PACKAGE__->BUILD;#build accessors during load

#find and instantiate a user object by login name
sub by_login_name {
    state $sql = $_[0]->SQL('SELECT') . ' WHERE login_name=?';
    return shift->query($sql, shift);
}

sub name {
    ref($_[0]) || Carp::croak("The method $_[0]::name must be called only on instances!");
    return $_[0]->{name} ||= do {
        Mojo::Util::trim(
            ($_[0]->{data}{first_name} || '') . ' ' . ($_[0]->{data}{last_name} || ''))
          || $_[0]->{data}{login_name};
    };
}

sub adduser {
    my $class = shift;
    my $args  = $class->_get_obj_args(@_);
    state $dbix = $class->dbix;

    state $GR = 'Ado::Model::Groups';    #shorten class name
    my ($group, $user, $ingroup);
    my $result = {};
    my $try    = eval {
        $dbix->begin_work;

        #First we need a primary group. Does it exist?
        if (!$GR->by_name($args->{login_name})->id) {
            $group = $GR->create(
                name        => $args->{login_name},
                disabled    => 0,
                description => 'Primary group for user ' . $args->{login_name},
                created_by => $args->{created_by} || 1,
            );
            $result->{group} = $group;
        }
        else {
            carp("Group $args->{login_name} already exists!..");
        }

        #Let us create the user now...
        if (!(($user = $class->by_login_name($args->{login_name})) && $user->id)) {
            $user = $class->create(
                first_name     => $args->{first_name},
                last_name      => $args->{last_name},
                login_name     => $args->{login_name},
                login_password => $args->{login_password},
                disabled       => $args->{disabled},
                tstamp         => $args->{tstamp},
                created_by     => $args->{created_by},
                changed_by     => $args->{changed_by},
                stop_date      => $args->{stop_date},
                start_date     => $args->{start_date},
                group_id       => $args->{group_id},
            );
            $result->{user} = $user;

            #And link them additionally
            Ado::Model::UserGroup->insert(user_id => $user->id, group_id => $group->id);
        }
        else {
            carp("User $args->{login_name} already exists!..");
        }

        #Do they want actually (or additionally) to add this user to a group?
        if ($args->{ingroup}) {
            if (!(($ingroup = $GR->by_name($args->{ingroup}))->id)) {
                $ingroup = $GR->create(
                    name        => $args->{ingroup},
                    disabled    => 0,
                    description => 'Additional group initially created for user '
                      . $args->{login_name},
                    created_by => $args->{created_by} || 1,
                );
                $result->{ingroup} = $ingroup;
            }

            #Link them
            Ado::Model::UserGroup->insert(user_id => $user->id, group_id => $ingroup->id);
        }

        $dbix->commit;
    };
    unless ($try) {
        $dbix->rollback or Carp::croak($dbix->error);
        croak("ERROR adding user(rolling back):[$@]");
    }
    return $user;
}
__PACKAGE__->SQL(SELECT_groups => <<"SQL");
        SELECT name 
        FROM groups 
        WHERE id IN (SELECT group_id FROM user_group WHERE user_id=?)
SQL

sub ingroup {
    my ($self, $group) = @_;
    $self->{ingroup} ||= $self->dbix->query(__PACKAGE__->SQL('SELECT_groups'), $self->id)->flat;
    return List::Util::first { $_ eq $group } @{$self->{ingroup}} if $group;
    return $self->{ingroup};
}

1;

__END__

=pod

=encoding utf8

=head1 NAME

A class for TABLE users in schema main

=head1 SYNOPSIS

    #a helper from Ado::Plugin::AdoHelpers providing the current user
    $app->helper(
        'user' => sub {
            Ado::Model::Users->by_login_name(shift->session->{login_name} // 'guest');
        }
    );
    
    #in a controller
    #Find a user by login_name and change the current user
    my $user       = Ado::Model::Users->by_login_name($login_name);
    $c->user($user);

    #in a template
    <h1>Hello, <%=user->name%>!</h1>

    #Add a new user
    Ado::Model::Users->adduser(login_name=>'petko'...);

=head1 DESCRIPTION

This class maps to rows in table C<users>. 

=head1 ATTRIBUTES

Ado::Model::Users inherits all attributes from Ado::Model provides the following.

=head2 name

Readonly. Returns concatenated L</first_name> and L</last_name> of the user 
or the username (in case the first two are not available).

    # Hello, Guest
    <h1>Hello, <%=user->name%>!</h1>

=head1 COLUMNS

Each column from table C<users> has an accessor method in this class.

=head2 id

=head2 group_id

=head2 login_name

=head2 login_password

=head2 first_name

=head2 last_name

=head2 email

=head2 description

=head2 created_by

=head2 changed_by

=head2 tstamp

=head2 reg_date

=head2 disabled

=head2 start_date

=head2 stop_date

=head1 ALIASES

none

=head1 METHODS

Ado::Model::Users inherits all methods from Ado::Model and provides the following
additional methods:

=head2 by_login_name

Selects a user by login_name column.

    my $user = Ado::Model::Users->by_login_name('guest');
    say $user->login_name if $user->id;

=head2 adduser

Given enough parameters creates a new user object and inserts it into the table C<users>.
Creates a primary group for the user with the same group C<name>.
If a user with the same C<login_name> exists already tries to add the user to 
the passed C<ingroup>. If the group C<ingroup> does not exists, the group (with
C<name> as passed C<ingroup>) is created and the user is added to it.
Throws an exception if any of the above fails.
Returns (the eventually newly created) user object.

    my $user = Ado::Model::Users->adduser(
        login_name     => $login_name,
        login_password => Mojo::Util::sha1_hex($login_name.$login_password)
    );

    my $user = Ado::Model::Users->adduser(login_name=>'petko',ingroup=>'admin');
    say $user->name . ' was added to group admin!' if $user->ingroup('admin');

=head2 ingroup

Given a group name returns true if a user is member of the group.
Returns false otherwise.

    say $user->name . ' is admin!' if $user->ingroup('admin');

=head1 GENERATOR

L<DBIx::Simple::Class::Schema>

This class contains also custom code.

=head1 SEE ALSO


L<Ado::Model>, L<DBIx::Simple::Class>, L<DBIx::Simple::Class::Schema>
