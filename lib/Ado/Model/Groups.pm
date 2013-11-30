package Ado::Model::Groups;    #A table/row class
use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(Ado::Model);

sub is_base_class { return 0 }
my $TABLE_NAME = 'groups';

sub TABLE       { return $TABLE_NAME }
sub PRIMARY_KEY { return 'id' }
my $COLUMNS = ['id', 'name', 'description', 'created_by', 'changed_by', 'disabled'];

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
    'name' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,255}$)/
    },
    'id'          => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'description' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,255}$)/
    },
    'created_by' => {'allow' => qr/(?^x:^-?\d{1,}$)/}
};

sub CHECKS { return $CHECKS }

__PACKAGE__->QUOTE_IDENTIFIERS(0);

#__PACKAGE__->BUILD;#build accessors during load

1;

__END__

=pod

=encoding utf8

=head1 NAME

A class for TABLE groups in schema main

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 COLUMNS

Each column from table C<groups> has an accessor method in this class.

=head2 id

=head2 name

=head2 description

=head2 created_by

=head2 changed_by

=head2 disabled

=head1 ALIASES

=head1 GENERATOR

L<DBIx::Simple::Class::Schema>

=head1 SEE ALSO


L<Ado::Model>, L<DBIx::Simple::Class>, L<DBIx::Simple::Class::Schema>
