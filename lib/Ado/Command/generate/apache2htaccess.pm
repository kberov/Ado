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
    $args->{module} = [];
    GetOptionsFromArray \@args,
      'v|verbose'   => \$args->{verbose},
      'm|module=s@' => \$args->{module};
    @{$args->{module}} = split(/,/, join(',', @{$args->{module}}));
    Carp::croak $self->usage unless $args->{module};
    say 'Using arguments:' . $self->app->dumper($args) if $args->{verbose};

    my $template_file = $self->rel_file('templates/partials/apache2htaccess.ep');
    my $config = Mojo::Template->new->render_file($template_file, $args);
    if ($args->{config_file}) {
        say 'Writing ' . $args->{config_file} if $args->{verbose};
        Mojo::Util::spurt($config, $args->{config_file});
    }
    else {
        say $config;
    }
    return;

}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Command::generate::apache2htaccess - Generates Apache2 .htaccess file

=head1 SYNOPSIS
  
  Usage:
  #on the command-line 
  
  $ bin/ado generate apache2htaccess --module cgi,fcgi > $MOJO_HOME/.htaccess
  
  #programatically
  use Ado::Command::generate::apache2htaccess;
  my $v = Ado::Command::generate::apache2htaccess->new;
  $v->run('--module' => 'cgi,fcgi');

=head1 DESCRIPTION

L<Ado::Command::generate::apache2htaccess> 
generates an Apache2 C<.htaccess> configuration file for your L<Ado> application.
You can use this command with a shared hosting account.

This is a core command, that means it is always enabled and its code a good
example for learning to build new commands, you're welcome to fork it.

=head1 OPTIONS

Below are the options this command accepts described in L<Getopt::Long>
notation.

=head2 n|module=s@

Apache modules to use for running C<ado>. Currently supported modules are
C<mod_cgi> and C<mod_fcgi>. You can mention them both to add the corresponding
sections and Apache will use mod_fcgi if loaded.


=head1 ATTRIBUTES

L<Ado::Command::generate::apache2htaccessn> inherits all attributes from
L<Ado::Command::generate> and implements the following new ones.

=head2 args

Used for storing arguments from the commandline and then passing them to the
template 

  my $args = $self->args;

=head2 description

  my $description = $htaccess->description;
  $v              = $htaccess->description('Foo!');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $htaccess->usage;
  $v        = $htaccess->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS


L<Mojolicious::Command::generate::apache2htaccess> inherits all methods from 
L<Mojolicious::Command::generate> and implements the following new ones.

=head2 run

  $htaccess->run(@ARGV);

Run this command.


=head1 SEE ALSO

L<https://github.com/kraih/mojo/wiki/Apache-deployment>,
L<Apache - Upgrading to 2.4 from 2.2|http://httpd.apache.org/docs/2.4/upgrading.html>,
L<Mojolicious::Command::generate::apache2vhost>,
L<Mojolicious::Command::generate>, L<Getopt::Long>,
L<Ado::Command> L<Ado::Manual>,
L<Mojolicious>, L<Mojolicious::Guides::Cookbook/DEPLOYMENT>.

=cut
