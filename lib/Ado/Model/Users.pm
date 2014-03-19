package Ado::Model::Users;    #A table/row class
use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(Ado::Model);

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
    'changed_by' => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'disabled'   => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^-?\d{1,1}$)/,
        'default'  => '1'
    },
    'tstamp' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^-?\d{1,}$)/
    },
    'login_password' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,80}$)/
    },
    'stop_date' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^-?\d{1,}$)/
    },
    'description' => {
        'allow'   => qr/(?^x:^.{1,255}$)/,
        'default' => 'NULL'
    },
    'last_name' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,255}$)/
    },
    'email' => {
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
    'id'         => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'login_name' => {'allow' => qr/(?^x:^.{1,100}$)/},
    'created_by' => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'first_name' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,255}$)/
    }
};

sub CHECKS { return $CHECKS }

sub by_login_name {
    return shift->query("SELECT * FROM $TABLE_NAME WHERE login_name=?", shift);
}

sub name {
    return $_[0]->{name} ||= do {
        Mojo::Util::trim(
            ($_[0]->{data}{first_name} || '') . ' ' . ($_[0]->{data}{last_name} || ''))
          || $_[0]->{data}{login_name};
    };
}
__PACKAGE__->QUOTE_IDENTIFIERS(0);

#__PACKAGE__->BUILD;#build accessors during load

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

=head1 DESCRIPTION

This class maps to table C<users>. 

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

Ado::Model::Users inherits all methods from Ado::Model and provides the following.

=head2 by_login_name

Selects a user by login_name column.

    my $user = Ado::Model::Users->by_login_name('guest');
    say $user->login_name if $user->id;

=head1 GENERATOR

L<DBIx::Simple::Class::Schema>

=head1 SEE ALSO


L<Ado::Model>, L<DBIx::Simple::Class>, L<DBIx::Simple::Class::Schema>
