package Ado::Command::generate::apache2htaccess;
use Mojo::Base 'Ado::Command';
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => "Generates Apache2 .htaccess file.\n";
has usage       => sub { shift->extract_usage };
has args        => sub { {} };

sub run {
    my ($self, @args) = @_;
    my $home = $self->app->home;
    my $args = $self->args;
    GetOptionsFromArray \@args,
      'n|ServerName=s'   => \$args->{ServerName},
      'p|port=i'         => \($args->{port} = 80),
      'A|ServerAlias=s'  => \$args->{ServerAlias},
      'a|ServerAdmin=s'  => \$args->{ServerAdmin},
      'D|DocumentRoot=s' => \($args->{DocumentRoot} = $home),
      'c|config_file=s'  => \$args->{config_file},
      'v|verbose'        => \$args->{verbose},
      's|with_suexec'    => \$args->{with_suexec};

    Carp::croak $self->usage unless $args->{ServerName};

    return;
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Command::generate::apache2htaccess - Generates Apache2 .htaccess file

=head1 SYNOPSIS
  
  #on the command-line 
  
  $ bin/ado generate apache2htaccess --deployment cgi,fcgi,psgi,mod_proxy \
   > $MOJO_HOME/.htaccess
  
  #programatically
  use Ado::Command::generate::apache2htaccess;
  my $v = Ado::Command::generate::apache2htaccess->new;
  $v->run('--ServerName' => 'example.com', '-p' => 8080);

=head1 DESCRIPTION

L<Ado::Command::generate::apache2htaccess> 
generates a minimal Apache2 Virtual Host configuration file for your L<Ado> application.
You can not use this command with a shared hosting account.

This is a core command, that means it is always enabled and its code a good
example for learning to build new commands, you're welcome to fork it.

=head1 OPTIONS

Below are the options this command accepts described in L<Getopt::Long>
notation.

=head2 n|ServerName=s


=head1 ATTRIBUTES

L<Ado::Command::generate::apache2htaccessn> inherits all attributes from
L<Ado::Command::generate> and implements the following new ones.

=head2 args

Used for storing arguments from the commandline and then passing them to the
template 

  my $args = $self->args;

=head2 description

  my $description = $v->description;
  $v              = $v->description('Foo!');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $v->usage;
  $v        = $v->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS


L<Mojolicious::Command::generate::apache2htaccess> inherits all methods from 
L<Mojolicious::Command::generate> and implements the following new ones.

=head2 run

  $get->run(@ARGV);

Run this command.


=head1 SEE ALSO

L<https://github.com/kraih/mojo/wiki/Apache-deployment>,
L<Mojolicious::Command::generate>, L<Getopt::Long>,
L<Ado::Command> L<Ado::Manual>,
L<Mojolicious>, L<Mojolicious::Guides>.

=cut
