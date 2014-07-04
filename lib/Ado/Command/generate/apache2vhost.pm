package Ado::Command::generate::apache2vhost;
use Mojo::Base 'Ado::Command';
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);

has description => "Generates minimal Apache2 Virtual Host configuration file.\n";
has usage       => sub { shift->extract_usage };
has args        => sub { {} };

sub run {
    my ($self, @args) = @_;
    state $app  = $self->app;
    state $home = $app->home;
    my $args = $self->args;
    GetOptionsFromArray \@args,
      'n|ServerName=s'   => \$args->{ServerName},
      'p|port=i'         => \($args->{port} = 80),
      'A|ServerAlias=s'  => \$args->{ServerAlias},
      'a|ServerAdmin=s'  => \$args->{ServerAdmin},
      'D|DocumentRoot=s' => \($args->{DocumentRoot} = $home),
      'c|config_file=s'  => \$args->{config_file},
      'v|verbose'        => \$args->{verbose},
      'u|user=s'         => \$args->{user},
      'g|group=s'        => \$args->{group},
      's|with_suexec'    => \$args->{with_suexec};

    Carp::croak $self->usage unless $args->{ServerName};

    $args->{ServerAlias} //=
      $$args{ServerName} =~ /^www\./ ? $$args{ServerName} : 'www.' . $$args{ServerName};
    $args->{ServerAdmin} //= 'webmaster@' . $args->{ServerName};
    $args->{user} //= ($ENV{USER} || getlogin || 'nobody');
    $args->{group} //= $( =~ /^(\S+?)/ && getgrgid($1);
    $args->{DocumentRoot} =~ s|\\|/|g;

    say STDERR 'Using arguments:' . $app->dumper($args) if $args->{verbose};

    my $template_file = $self->rel_file('templates/partials/apache2vhost.ep');
    my $config = Mojo::Template->new->render_file($template_file, $args);
    if ($args->{config_file}) {
        say STDERR 'Writing ' . $args->{config_file} if $args->{verbose};
        Mojo::Util::spurt($config, $args->{config_file});
    }
    else {
        say $config;
    }
    return $self;
}

1;


=pod

=encoding utf8

=head1 NAME

Ado::Command::generate::apache2vhost - Generates minimal Apache2 Virtual Host configuration file

=head1 SYNOPSIS
  
On the command-line:

  $ bin/ado generate apache2vhost --ServerName example.com \
   > etc/001-example.com.vhost.conf

Review your newly generated C<001-example.com.vhost.conf>!!!
Create link to your generated configuration.

  # ln -siv /home/you/dev/Ado/etc/001-example.com.vhost.conf \
  /etc/apache2/sites-enabled/001-example.com.vhost.conf
  
  # service apache2 reload

Generate your C<.htaccess> file. Since you own the machine,
you can put its content into the C<001-example.com.vhost.conf> file.

  $ bin/ado generate apache2htaccess --module fcgi \
   > $MOJO_HOME/.htaccess

Programatically:

  use Ado::Command::generate::apache2vhost;
  my $vhost = Ado::Command::generate::apache2vhost->new;
  $vhost->run('--ServerName' => 'example.com', '-p' => 8080);

=head1 DESCRIPTION

L<Ado::Command::generate::apache2vhost> 
generates a minimal Apache2 Virtual Host configuration file for your L<Ado> application.

This is a core command, that means it is always enabled and its code a good
example for learning to build new commands, you're welcome to fork it.

=head1 OPTIONS

Below are the options this command accepts described in L<Getopt::Long>
notation.

=head2 n|ServerName=s

Fully Qualified Domain Name for the virtual host. B<Required!>
See also documentation for Apache2 directive ServerName.

=head2 p|port=i

Port on which this host will be served. Defaults to 80.

=head2 A|ServerAlias=s

Alias for ServerName. Defaults to C<'www.'.$ServerName>.
See also documentation for Apache2 directive ServerAlias.

=head2 a|ServerAdmin=s

Email of the administrator for this host - you.
Defaults to webmaster@$ServerName.
See also documentation for Apache2 directive ServerAdmin.


=head2 D|DocumentRoot=s

DocumentRoot for the virtual host. Defaults to C<$ENV{MOJO_HOME}>.
See also documentation for Apache2 directive DocumentRoot.

=head2 c|config_file=s

Full path to the file in which the configuaration will be written.
If not provided the configuaration is printed to the screen.

=head2 s|with_suexec

Adds C<SuexecUserGroup> directive which is effective only 
if C<mod_suexec> is loaded. The user and the group are guessed from the 
user running the command.

=head3 u|user=s

User to be used with suexec.

=head3 g|group=s
      
Group to be used with suexec.

=head3 v|verbose

Verbose output.

=head1 ATTRIBUTES

L<Ado::Command::generate::apache2vhostn> inherits all attributes from
L<Ado::Command::generate> and implements the following new ones.

=head2 args

Used for storing arguments from the commandline and then passing them to the
template 

  my $args = $self->args;

=head2 description

  my $description = $vhost->description;
  $v              = $vhost->description('Foo!');

Short description of this command, used for the command list.

=head2 env

Reference to C<%ENV>.


=head2 usage

  my $usage = $vhost->usage;
  $v        = $vhost->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS


L<Ado::Command::generate::apache2vhost> inherits all methods from 
L<Ado::Command::generate> and implements the following new ones.

=head2 run

  $vhost->run(@ARGV);

Run this command. Returns C<$self>.


=head1 SEE ALSO

L<Apache deployment|https://github.com/kraih/mojo/wiki/Apache-deployment>,
L<Apache - Upgrading to 2.4 from 2.2|http://httpd.apache.org/docs/2.4/upgrading.html>,
L<Ado::Command::generate::apache2htaccess>,
L<Mojolicious::Command::generate>, L<Getopt::Long>,
L<Ado::Command> L<Ado::Manual>,
L<Mojolicious>, L<Mojolicious::Guides::Cookbook/DEPLOYMENT>

=cut
