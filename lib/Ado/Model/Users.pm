package Ado::Model::Users;    #A table/row class
use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(Ado::Model);
use Carp;
use Email::Address;
sub is_base_class { return 0 }
my $CLASS      = __PACKAGE__;
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
        'allow'    => qr/(?^x:^\d{1,10}$)/
    },
    'login_password' => {
        'required' => 1,
        'defined'  => 1,

        #result of Mojo::Util::sha1_hex($login_name.$login_password)
        'allow' => qr/^[A-Fa-f0-9]{40}$/x
    },
    'stop_date'   => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'description' => {
        'allow'   => qr/(?^x:^.{0,255}$)/,
        'default' => ''
    },
    'last_name' => {'allow' => qr/(?^x:^.{1,100}$)/},
    'email'     => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => $Email::Address::addr_spec
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
    'first_name' => {'allow' => qr/(?^x:^.{1,100}$)/}
};

sub CHECKS { return $CHECKS }

__PACKAGE__->QUOTE_IDENTIFIERS(0);

#__PACKAGE__->BUILD;#build accessors during load

#find and instantiate a user object by login name
sub by_login_name {
    state $sql = $_[0]->SQL('SELECT') . ' WHERE login_name=?';
    return $_[0]->query($sql, $_[1]);
}

sub name {
    ref($_[0]) || Carp::croak("The method $_[0]::name must be called only on instances!");
    return $_[0]->{name} ||= do {
        Mojo::Util::trim(
            ($_[0]->{data}{first_name} || '') . ' ' . ($_[0]->{data}{last_name} || ''))
          || $_[0]->{data}{login_name};
    };
}

sub add {
    my $class = shift;
    my $args  = $class->_get_obj_args(@_);
    state $dbix = $class->dbix;

    state $GR = 'Ado::Model::Groups';    #shorten class name
    my ($group, $user);
    my $try = eval {
        $dbix->begin_work;

        #First we need a primary group for the user.
        $group = $GR->create(
            name        => $args->{login_name},
            disabled    => 0,
            description => 'Primary group for user ' . $args->{login_name},
            created_by => $args->{created_by} || 1,
        );

        #Let us create the user now...
        $user = $class->create(
            first_name     => $args->{first_name},
            last_name      => $args->{last_name},
            login_name     => $args->{login_name},
            login_password => $args->{login_password},
            email          => $args->{email},
            disabled       => $args->{disabled},
            tstamp         => time,
            reg_date       => time,
            created_by     => $args->{created_by},
            changed_by     => $args->{changed_by},
            stop_date      => $args->{stop_date},
            start_date     => $args->{start_date},
            description    => $args->{description},
            group_id       => $group->id,
        );

        #And link them additionally
        Ado::Model::UserGroup->create(
            user_id  => $user->id,
            group_id => $group->id
        );
        $dbix->commit;
    };
    unless ($try) {
        $dbix->rollback or croak($dbix->error);
        carp("ERROR adding user(rolling back):[$@]");
    }
    return $user;
}

#Add an existing user to a potentially not existing group(create the group)
sub add_to_group {
    my $self = shift;
    my $args = $self->_get_obj_args(@_);
    state $dbix = $self->dbix;
    state $GR   = 'Ado::Model::Groups';    #shorten class name
    my $ingroup;
    my $try = eval {
        $dbix->begin_work;

        #Create the group if it does not exist yet
        if (!(($ingroup = $GR->by_name($args->{ingroup}))->id)) {
            $ingroup = $GR->create(
                name        => $args->{ingroup},
                disabled    => 0,
                description => 'Additional group initially created for user ' . $self->login_name,
                created_by => $args->{created_by} || 1,
            );
        }

        #Link them
        Ado::Model::UserGroup->create(
            user_id  => $self->id,
            group_id => $ingroup->id
        );
        $dbix->commit;
    };
    unless ($try) {
        $dbix->rollback or croak($dbix->error);
        carp("ERROR adding user to group (rolling back):[$@]");
    }
    return $ingroup;
}

__PACKAGE__->SQL(SELECT_group_names => <<"SQL");
    SELECT name FROM groups
        WHERE id IN (SELECT group_id FROM user_group WHERE user_id=?)
SQL

sub ingroup {
    my ($self, $group) = @_;
    state $sql = __PACKAGE__->SQL('SELECT_group_names');
    my @groups = $self->dbix->query($sql, $self->id)->flat;
    if ($group) {
        return List::Util::first { $_ eq $group } @groups;
    }
    return @groups;
}

$CLASS->SQL('user_id_by_group_name' => <<"UG");
    SELECT user_id FROM user_group WHERE group_id = 
        (SELECT id FROM groups  WHERE name = ?)
UG

$CLASS->SQL('by_group_name' => <<"SQL");
    SELECT id, login_name, first_name, last_name, email
    FROM ${\ $CLASS->TABLE }
    WHERE id IN(${\ $CLASS->SQL('user_id_by_group_name') })
        AND (disabled=0 AND (stop_date>? OR stop_date=0) AND start_date<?) 
    ORDER BY first_name, last_name ASC

SQL

#Selects users belonging to a group only.
sub by_group_name {
    my ($class, $group, $limit, $offset) = @_;

    state $SQL = $class->SQL('by_group_name') . $CLASS->SQL_LIMIT('?', '?');
    $limit  //= 500;
    $offset //= 0;
    my $time = time;
    my @a = $class->query($SQL, $group, $time, $time, $limit, $offset);
    return map { +{%{$_->data}, name => $_->name} } @a;
}

1;

=pod

=encoding utf8

=head1 NAME

A class for TABLE users in schema main

=head1 SYNOPSIS


    #In a controller use the helper.
    #Find a user by login_name and change the current user
    my $user       = Ado::Model::Users->by_login_name($login_name);
    $c->user($user);

    #in a template
    <h1>Hello, <%=user->name%>!</h1>

    #Create a new user.
    my $user = Ado::Model::Users->add(login_name=>'petko'...);
    #Add the user to a group
    $user->add_to_group('cool');

=head1 DESCRIPTION

This class maps to rows in table C<users>. 

=head1 ATTRIBUTES

Ado::Model::Users inherits all attributes from Ado::Model
and provides the following.

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

=head2 add

Given enough parameters creates a new user object and inserts it 
into the table C<users>.
Creates a primary group for the user with the same group C<name>.
Throws an exception if any of the above fails.
Returns (the eventually newly created) user object.

    my $user = Ado::Model::Users->add(
        login_name     => $login_name,
        login_password => Mojo::Util::sha1_hex($login_name.$login_password)
    );

=head2 add_to_group

Adds a user with C<login_name> to a group.
Creates the group if it does not already exists.
Returns the group.

    $ingroup = $user->add_to_group(ingroup=>'admin');

=head2 by_group_name

Selects active users 
(C<WHERE (disabled=0 AND (stop_date>$now OR stop_date=0) AND start_date<$now )>)
belonging to a given group only
and within a given range, ordered by
C<first_name, last_name> alphabetically.
C<$limit> defaults to 500 and C<$offset> to 0.
Only the following fields are retrieved: C<id, login_name, first_name, last_name, email>.

Returns an array of hashes. The L</name> method is executed for each 
row in the resultset and the evaluation is available via key 'name'.

  #get contacts of the user 'berov'
  my @users = Ado::Model::Users->by_group_name('vest_contacts_for_berov', $limit, $offset);

=head2 by_login_name

Selects a user by login_name column.

    my $user = Ado::Model::Users->by_login_name('guest');
    say $user->login_name if $user->id;

=head2 ingroup

Given a group name returns true if a user is member of the group.
Returns false otherwise.
Returns a list of all group names a user belongs to if no group name passed.

    say $user->name . ' is admin!' if $user->ingroup('admin');
    say $user->name .' is member of the following groups:' 
    . join(', ', $user->ingroup);

=head1 GENERATOR

L<DBIx::Simple::Class::Schema>

This class contains also custom code.

=head1 SEE ALSO

L<Ado::Command::adduser>, L<Email::Address>,
L<Ado::Model>, L<DBIx::Simple::Class>, L<DBIx::Simple::Class::Schema>

=cut
