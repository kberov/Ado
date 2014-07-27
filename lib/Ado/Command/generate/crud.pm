package Ado::Command::generate::crud;
use Mojo::Base 'Ado::Command::generate';
use Mojo::Util qw(camelize class_to_path decamelize);
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Time::Piece ();

has description => "Generates directory structures for Ado-specific CRUD..\n";
has usage => sub { shift->extract_usage };

sub run {
    my ($self, @args) = @_;
    my $args = $self->args;
    GetOptionsFromArray \@args,
      'C|controller_namespace=s' => \$args->{controller_namespace},
      'M|model_namespace=s' => \$args->{model_namespace},
      'N|no_dsc_code'=> => \$args->{no_dsc_code},
      'O|overwrite=i' => \$args->{overwrite},
      'd|dsn=s'         => \$args->{dsn},
      'L|lib_root=s'       => \$args->{lib_root},
      'T|templates_root' => \$args->{templates_root},
      't|tables' =>\$args->{tables},
      'v|verbose'       => \$args->{verbose},
      ;

    Carp::croak $self->usage unless $args->{tables};


    return $self;
}


1;


=pod

=encoding utf8

=head1 NAME

Ado::Command::generate::crud - Generates MVC set of files

=head1 SYNOPSIS

sld

=head1 DESCRIPTION

L<Ado::Command::generate::crud> generates directory structure for
a fully functional MVC set, based on existing tables in the database.
Internally this generator uses L<DBIx::Simple::Class::Schema>
to generate the classes, used to manipulate the tables' content, 
if they are not already generated. If the Model classes already exist,
it creates only the controller classes and templates. The needed routes
are already described in C<etc/ado.conf>.

In the controller classes' actions you will find I<eventually working> code
for reading, creating, updating and deleting records from the tables you
specified on the command-line. The generated code uses
L<DBIx::Simple::Class::Schema> based classes.

In addition example code is created that uses only L<DBIx::Simple>. 
In case you prefer to use only L<DBIx::Simple> and not L<DBIx::Simple::Class>,
use the option L</no_dsc_code>. If you want pure L<DBI>, 
write the code your self.

The generated code is just boilerplate to give you a jump start, so you can
concentrate on writing your business-specific code. It is even recommended
to modify the generated code to suit your specific needs.

B<Disclaimer: I<This command is highly experimental!> 
The generated code is not even expected to work.>


=head1 OPTIONS

Below are the options this command accepts, described in L<Getopt::Long> notation.


=head1 ATTRIBUTES

L<Ado::Command::generate::crud> inherits all attributes from
L<Ado::Command::generate> and implements the following new ones.


=head2 description

  my $description = $command->description;
  $command        = $command->description('Foo!');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $command->usage;
  $command  = $command->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Ado::Command::generate::crud> inherits all methods from
L<Ado::Command> and implements the following new ones.

=head2 run

  $plugin->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Ado::Command::generate::adoplugin>,
L<Ado::Command::generate::apache2vhost>,
L<Ado::Command::generate::apache2htaccess>, L<Ado::Command::generate>,
L<Mojolicious::Command::generate>, L<Getopt::Long>,
L<Ado::Command> L<Ado::Manual>,
L<Mojolicious>, L<Mojolicious::Guides::Cookbook/DEPLOYMENT>

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





