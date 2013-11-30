package Ado::Model::Sessions;    #A table/row class
use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(Ado::Model);

sub is_base_class { return 0 }
my $TABLE_NAME = 'sessions';

sub TABLE       { return $TABLE_NAME }
sub PRIMARY_KEY { return 'id' }
my $COLUMNS = ['id', 'user_id', 'tstamp', 'sessiondata'];

sub COLUMNS { return $COLUMNS }
my $ALIASES = {};

sub ALIASES { return $ALIASES }
my $CHECKS = {
    'sessiondata' => {
        'required' => 1,
        'defined'  => 1
    },
    'tstamp' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^-?\d{1,11}$)/
    },
    'user_id' => {'allow' => qr/(?^x:^-?\d{1,11}$)/},
    'id'      => {'allow' => qr/(?^x:^.{1,40}$)/}
};

sub CHECKS { return $CHECKS }

__PACKAGE__->QUOTE_IDENTIFIERS(0);

#__PACKAGE__->BUILD;#build accessors during load

1;

__END__

=pod

=encoding utf8

=head1 NAME

A class for TABLE sessions in schema main

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 COLUMNS

Each column from table C<sessions> has an accessor method in this class.

=head2 id

=head2 user_id

=head2 tstamp

=head2 sessiondata

=head1 ALIASES

=head1 GENERATOR

L<DBIx::Simple::Class::Schema>

=head1 SEE ALSO


L<Ado::Model>, L<DBIx::Simple::Class>, L<DBIx::Simple::Class::Schema>
