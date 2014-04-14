package Ado::Model;    #The schema/base class
use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(DBIx::Simple::Class);
use Carp;

our $VERSION = '0.01';
sub is_base_class { return 1 }

sub dbix {

    # Singleton DBIx::Simple instance
    state $DBIx;
    return ($_[1] ? ($DBIx = $_[1]) : $DBIx)
      || Carp::croak('DBIx::Simple is not instantiated. Please first do '
          . $_[0]
          . '->dbix(DBIx::Simple->connect($DSN,$u,$p,{...})');
}


#The methods below are not generated but written additionally

sub select_range {
    my $class = shift;
    state $dbix = $class->dbix;

    #Could use "state" instead of "my"
    # if this method is in a specific table-class.
    my $SQL = $class->SQL('SELECT') . $class->SQL_LIMIT(@_);

    return $dbix->query($SQL)->objects($class);
}


1;

__END__

=pod

=encoding utf8

=head1 NAME

Ado::Model - the base schema class.

=head1 DESCRIPTION

This is the base class for using table records as plain Perl objects.
The subclasses are:

=over

=item L<Ado::Model::Domains> - A class for TABLE domains in schema main

=item L<Ado::Model::Groups> - A class for TABLE groups in schema main

=item L<Ado::Model::Sessions> - A class for TABLE sessions in schema main

=item L<Ado::Model::SessionsOld> - A class for TABLE sessions_old in schema main

=item L<Ado::Model::SqliteSequence> - A class for TABLE sqlite_sequence in schema main

=item L<Ado::Model::UserGroup> - A class for TABLE user_group in schema main

=item L<Ado::Model::Users> - A class for TABLE users in schema main

=back

=head2 ATTRIBUTES


=head2 METHODS

Ado::Model inherits all methods from 
and implements the following ones.

=head2 select_range

Returns an array of records.

  my @users = Ado::Model::Users->select_range(2);
  #users 1, and 2
  my @users = Ado::Model::Users->select_range(2,4);
  #users 3, and 4
  

=head1 GENERATOR

L<DBIx::Simple::Class::Schema>


=head1 SEE ALSO


L<DBIx::Simple::Class::Schema>, L<DBIx::Simple::Class>, L<DBIx::Simple>, L<Mojolicious::Plugin::DSC>

=head1 LICENSE AND COPYRIGHT

berov...

=cut
