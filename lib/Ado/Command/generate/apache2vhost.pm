package Ado::Command::generate::apache2vhost;
use Mojo::Base 'Ado::Command';

use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Mojo::Util qw(decode encode);

has description => "Generates Apache2 Virtual Host configuration file.\n";
has usage       => sub { shift->extract_usage };
has args        => sub { {} };

sub run {
    my ($self, @args) = @_;
    my $home = $self->app->home;
    my $ServerName;
    say $self->app->dumper(\@args);
    my $args = $self->args;
    GetOptionsFromArray \@args,
      'n|ServerName=s'   => \$args->{ServerName},
      'p|port=i'         => \($args->{port} = 80),
      'A|ServerAlias=s'  => \$args->{ServerAlias},
      'a|ServerAdmin=s'  => \$args->{ServerAdmin},
      'D|DocumentRoot=s' => \($args->{DocumentRoot} = $home),
      'v|verbose'        => \$args->{verbose};

    @args = map { decode 'UTF-8', $_ } @args;
    die $self->usage unless $args->{ServerName};
    $args->{ServerAlias} //=
      $$args{ServerName} =~ /^www\./ ? $$args{ServerName} : 'www.' . $$args{ServerName};
    $args->{ServerAdmin} //= 'webmaster@' . $args->{ServerName};

    say Mojo::Template->new->render_file($self->rel_file('templates/partials/apache2vhost.ep'),
        $args);
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Command::generate::apache2vhost - Generates Apache2 Virtual Host configuration file

=head1 SYNOPSIS
  
  #on the command-line 
  ado generate apache2vhost --ServerName example.com

  #programatically
  use Ado::Command::generate::apache2vhost;
  my $v = Ado::Command::generate::apache2vhost->new;
  $v->run('--ServerName' => 'example.com', '-p' => 8080);

=head1 DESCRIPTION

L<Ado::Command::generate::apache2vhost> 
generates Apache2 Virtual Host configuration file for your L<Ado> application.

This is a core command, that means it is always enabled and its code a good
example for learning to build new commands, you're welcome to fork it.

=head1 OPTIONS

=head2 n|ServerName=s

Fully Qualified Domain Name for the virtual host. Required!

=head2 p|port=i

Port on which this host will be served. Defaults to 80.

=head2 A|ServerAlias=s

Alias for ServerName. Defaults to C<'www.'$ServerName>.

=head2 a|ServerAdmin=s

=head1 ATTRIBUTES

L<Ado::Command::generate::apache2vhostn> inherits all attributes from
L<Ado::Command::generate> and implements the following new ones.

=head2 description

  my $description = $v->description;
  $v              = $v->description('Foo!');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $v->usage;
  $v        = $v->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS


L<Mojolicious::Command::generate::apache2vhost> inherits all methods from 
L<Mojolicious::Command::generate> and implements the following new ones.

=head2 run

  $get->run(@ARGV);

Run this command.


=head1 SEE ALSO

L<Mojolicious::Command::generate>, L<Getopt::Long>,
L<Ado::Command> L<Ado::Manual>,
L<Mojolicious>, L<Mojolicious::Guides>.

=cut
