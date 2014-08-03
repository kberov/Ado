package Ado::Model;    #The schema/base class
use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(DBIx::Simple::Class);
use Carp;
use DBIx::Simple::Class::Schema;

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

# Generates classes from tables on the fly and returns the classname.
sub table_to_class {
    my ($class, $args) = shift->_get_obj_args(@_);
    state $tables = {};
    my $table = $args->{table};

    # already generated?
    return $tables->{$table} if (exists $tables->{$table});

    $args->{namespace} //= $class;
    my $class_name = $args->{namespace} . '::' . Mojo::Util::camelize($table);

    # loaded from file?
    return $tables->{$table} = $class_name
      if $INC{Mojo::Util::class_to_path($class_name)};
    state $connected = DBIx::Simple::Class::Schema->dbix($class->dbix) && 1;
    my $perl_code = DBIx::Simple::Class::Schema->load_schema(
        namespace => $args->{namespace},
        table     => $table,
        type      => $args->{type} || "'TABLE','VIEW'",
    );
    Carp::croak($@) unless (eval "{$perl_code}");    ## no critic (ProhibitStringyEval)

    #TODO: Expose the package name from DBIx::Simple::Class::Schema.
    $tables->{$table} = $class_name;
    return $tables->{$table};
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

=head2 table_to_class

Generates classes from tables on the fly and returns the classname.

  state $table_class = Ado::Model->table_to_class(
      namespace => 'Foo', # defaults to Ado::Model
      table     => 'pages',
      type      => 'TABLE'
  );

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

=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2014 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that
modifications are open source. However, software that includes
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut
