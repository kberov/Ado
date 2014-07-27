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
    GetOptionsFromArray(
        \@args,
        'C|controller_namespace=s' => \$args->{controller_namespace},
        'd|dsn=s'                  => \$args->{dsn},
        'M|model_namespace=s'      => \$args->{model_namespace},
        'N|no_dsc_code'            => => \$args->{no_dsc_code},
        'O|overwrite'            => \$args->{overwrite},
        'L|lib_root=s'             => \$args->{lib_root},
        'T|templates_root=s'         => \$args->{templates_root},
        't|tables=s@'              => \$args->{tables},
    );

    @{$args->{tables}} = split(/\,/, join(',', @{$args->{tables} || []}));
    Carp::croak $self->usage unless scalar @{$args->{tables}};


    return $self;
}


1;


=pod

=encoding utf8

=head1 NAME

Ado::Command::generate::crud - Generates MVC set of files

=head1 SYNOPSIS

  Usage:
  #on the command-line
  # for specific tables.
  $ bin/ado generate crud --tables='news,articles'
  
  # for all tables containing 'foo' in their names.
  $ bin/ado generate crud --tables='%foo%'
  
  # for all tables!..
  $ bin/ado generate crud --tables='%'

  #programatically
  use Ado::Command::generate::crud;
  my $v = Ado::Command::generate::crud->new;
  $v->run(-t => 'news,articles');

=head1 DESCRIPTION

L<Ado::Command::generate::crud> generates directory structure for
a fully functional 
L<MVC|http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller> 
set of files, based on existing tables in the database.
You should have already created the tables in the database.
This tool purpose is to promote 
L<RAD|http://en.wikipedia.org/wiki/Rapid_application_development>
and help programmers new to L<Ado> and L<Mojolicious> to quickly create
fully functional applications.

Internally this generator uses L<DBIx::Simple::Class::Schema>
to generate the classes, used to manipulate the tables' records, 
if they are not already generated. If the I<Model> classes already exist,
it creates only the controller classes and templates. The needed routes
are already described in C<etc/ado.conf>.

In the controller classes' actions you will find I<eventually working> code
for reading, creating, updating and deleting records from the tables you
specified on the command-line. The generated code uses
L<DBIx::Simple::Class::Schema> based classes.

In addition, example code is created that uses only L<DBIx::Simple>. 
In case you prefer to use only L<DBIx::Simple> and not L<DBIx::Simple::Class>,
use the option C<'N|no_dsc_code'>. If you want pure L<DBI>, 
write the code your self.

The generated code is just boilerplate to give you a jump start, so you can
concentrate on writing your business-specific code. It is assumed that you will modify the generated code to suit your specific needs.

B<Disclaimer: I<This command is highly experimental!> 
The generated code is not even expected to work properly.>

=head1 OPTIONS

Below are the options this command accepts, described in L<Getopt::Long> notation.


=head2 C|controller_namespace=s

The namespace for the controller classes to be generated.
Defaults to  C<app-E<gt>routes-E<gt>namespaces-E<gt>[0]>, usuallly 
L<Ado::Control>. If you decide to use another namespace for the controllers,
do not forget to add it to the list C<app-E<gt>routes-E<gt>namespaces> 
in C<etc/ado.conf> or your plugin configuration file.

=head2 d|dsn=s

Connection string parsed using L<DBI/parse_dsn> and passed to 
L<DBIx::Simple/connect>. See also L<Mojolicious::Plugin::DSC/dsn>.

=head2 M|model_namespace=s

The namespace for the model classes to be generated.
Defaults to L<Ado::Model>. If you wish however to use another namespace
for another database, you will have to add another item for 
L<Mojolicious::Plugin::DSC> to the list of loaded pligins in C<etc/ado.conf>
or in your plugin configuration. Yes, multiple database connections/schemas
are supported.

=head2 N|no_dsc_code

Boolean. If this option is passed the previous option (M|model_namespace=s)
is ignored. No table classes will be generated.

=head2 O|overwrite

If there are already generated files they will be ovwerwritten.

=head2 L|lib_root=s

Defaults to C<lib> relative to the current dierctory.
If you installed L<Ado> in some custom path and you wish to set it
to e.g. C<site_lib>, use this option. Do not forget to add this
directory to C<$ENV{PERL5LIB}>, so the classes can be found by C<perl>.

=head2 T|templates_root=s

Defaults to C<app-E<gt>renderer-E<gt>paths-E<gt>[0]>. This is uasually
C<templates> directory. If you want to use naother directory,
doe not forget to add it to the C<app-E<gt>renderer-E<gt>paths> list.

=head2 t|tables=s@

Defaults to '%' which means all the tables from the specified database
with the C<d|dsn=s> option. Note that existing L<Ado::Model> classes 
will not be overwritten even if you specify C<O|overwrite>.


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

=head1 TODO

Add authentication checks to update and delete actions.

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


