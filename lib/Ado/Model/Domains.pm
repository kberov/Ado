package Ado::Model::Domains;    #A table/row class
use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(Ado::Model);

sub is_base_class { return 0 }
my $TABLE_NAME = 'domains';

sub TABLE       { return $TABLE_NAME }
sub PRIMARY_KEY { return 'id' }
my $COLUMNS = ['id', 'domain', 'site_name', 'description', 'owner_id', 'group_id', 'permissions',
    'published'];

sub COLUMNS { return $COLUMNS }
my $ALIASES = {};

sub ALIASES { return $ALIASES }
my $CHECKS = {
    'permissions' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,10}$)/,
        'default'  => '-rwxr-xr-x'
    },
    'description' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,255}$)/,
        'default'  => ''
    },
    'published' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^-?\d{1,1}$)/
    },
    'domain' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,63}$)/
    },
    'group_id' => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'id'       => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^-?\d{1,}$)/
    },
    'owner_id'  => {'allow' => qr/(?^x:^-?\d{1,}$)/},
    'site_name' => {
        'required' => 1,
        'defined'  => 1,
        'allow'    => qr/(?^x:^.{1,63}$)/
    }
};

sub CHECKS { return $CHECKS }

__PACKAGE__->QUOTE_IDENTIFIERS(0);

#__PACKAGE__->BUILD;#build accessors during load

1;

__END__

=pod

=encoding utf8

=head1 NAME

A class for TABLE domains in schema main

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 COLUMNS

Each column from table C<domains> has an accessor method in this class.

=head2 id

=head2 domain

=head2 site_name

=head2 description

=head2 owner_id

=head2 group_id

=head2 permissions

=head2 published

=head1 ALIASES

=head1 GENERATOR

L<DBIx::Simple::Class::Schema>

=head1 SEE ALSO


L<Ado::Model>, L<DBIx::Simple::Class>, L<DBIx::Simple::Class::Schema>
