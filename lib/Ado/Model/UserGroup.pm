package Ado::Model::UserGroup;    #A table/row class
use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(Ado::Model);

sub is_base_class { return 0 }
my $TABLE_NAME = 'user_group';

sub TABLE       { return $TABLE_NAME }
sub PRIMARY_KEY { return 'user_id' }
my $COLUMNS = ['user_id', 'group_id'];

sub COLUMNS { return $COLUMNS }
my $ALIASES = {};

sub ALIASES { return $ALIASES }
my $CHECKS = {
    'group_id' => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'user_id'  => {'allow' => qr/(?^x:^-?\d{1,}$)/}
};

sub CHECKS { return $CHECKS }

__PACKAGE__->QUOTE_IDENTIFIERS(0);

#__PACKAGE__->BUILD;#build accessors during load

1;

__END__

=pod

=encoding utf8

=head1 NAME

A class for TABLE user_group in schema main

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 COLUMNS

Each column from table C<user_group> has an accessor method in this class.

=head2 user_id

=head2 group_id

=head1 ALIASES

=head1 GENERATOR

L<DBIx::Simple::Class::Schema>

=head1 SEE ALSO


L<Ado::Model>, L<DBIx::Simple::Class>, L<DBIx::Simple::Class::Schema>
