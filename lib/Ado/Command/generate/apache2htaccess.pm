package Ado::Command::generate::apache2htaccess;
use Mojo::Base 'Ado::Command::generate';
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Mojo::File 'path';

has description => "Generates Apache2 .htaccess file.\n";
has usage => sub { shift->extract_usage };

# The next two are more or less stollen from File::Which.
my $IS_DOS = ($^O eq 'MSWin32' or $^O eq 'dos' or $^O eq 'os2');

sub _which {
    my ($self, $basename) = @_;
    return $self->{$basename} if $self->{$basename};
    my @pathext = ('');
    push @pathext, map {lc} split /;/, $ENV{PATHEXT} if $ENV{PATHEXT} && $IS_DOS;
    foreach my $path (File::Spec->path($ENV{PATH})) {
        foreach my $ext (@pathext) {
            my $exe = File::Spec->catfile($path, ($ext ? "$basename.$ext" : $basename));
            $exe =~ s|\\|/|g;
            return $self->{$basename} = $exe if -e $exe;
        }
    }
    return '';
}

sub run {
    my ($self, @args) = @_;
    state $app      = $self->app;
    state $home     = $app->home;
    state $ado_home = $app->ado_home;
    my $args = $self->args;
    GetOptionsFromArray \@args,
      'v|verbose'       => \$args->{verbose},
      'c|config_file=s' => \$args->{config_file},
      'M|modules=s@'    => \($args->{modules} //= []);

    @{$args->{modules}} = split(/\,/, join(',', @{$args->{modules}}));

    Carp::croak $self->usage unless scalar @{$args->{modules}};
    $args->{DocumentRoot} = $home;
    $args->{perl}         = $^X;

    if ($IS_DOS) {
        $args->{DocumentRoot} =~ s|\\|/|g;
        $args->{perl} =~ s|\\|/|g;
    }
    $args->{plackup} = $self->_which('plackup')
      if ( eval { require Plack }
        && eval { require FCGI }
        && eval { require FCGI::ProcManager }
        && eval { require Apache::LogFormat::Compiler });

    say STDERR 'Using arguments:' . $app->dumper($args) if $args->{verbose};
    state $rel_file      = 'templates/partials/apache2htaccess.ep';
    state $template_file = (
        -s $home->rel_file($rel_file)
        ? $home->rel_file($rel_file)
        : $ado_home->rel_file($rel_file)
    );
    $args->{moniker} = $app->moniker;
    my $config = Mojo::Template->new->render_file($template_file, $args);
    if ($args->{config_file}) {
        say STDERR 'Writing ' . $args->{config_file} if $args->{verbose};
        path($args->{config_file})->spurt($config);
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

Ado::Command::generate::apache2htaccess - Generates Apache2 .htaccess file

=head1 SYNOPSIS

  Usage:
  #on the command-line

  $ bin/ado generate apache2htaccess --modules cgi,fcgid > .htaccess

  #programatically
  use Ado::Command::generate::apache2htaccess;
  my $v = Ado::Command::generate::apache2htaccess->new;
  $v->run('--modules' => 'cgi,fcgid');

=head1 DESCRIPTION

L<Ado::Command::generate::apache2htaccess>
generates an Apache2 C<.htaccess> configuration file for your L<Ado> application.
You can use this command for a shared hosting account.

This is a core command, that means it is always enabled and its code a good
example for learning to build new commands, you're welcome to fork it.

=head1 OPTIONS

Below are the options this command accepts, described in L<Getopt::Long> notation.

=head2 c|config_file=s

Full path to the file in which the configuration will be written.
If not provided the configuration is printed to the screen.

=head3 v|verbose

Verbose output.

=head2 M|modules=s@

Apache modules to use for running C<ado>. Currently supported modules are
C<mod_cgi> and C<mod_fcgid>. You can mention them both to add the corresponding
sections and Apache will use C<mod_fcgid> if loaded or C<mod_cgi>
(almost always enabled).
The generated configuration for mod_fcgid will use L<Plack> (C<plackup>) or
L<Mojo::Server::FastCGI>. So make sure you have at least one of them installed.
L<Plack> is recommended.
To use L<Plack> with C<mod_fcgid> you will need to install
L<FCGI>, L<FCGI::ProcManager> and L<Apache::LogFormat::Compiler>.

=head1 ATTRIBUTES

L<Ado::Command::generate::apache2htaccess> inherits all attributes from
L<Ado::Command::generate> and implements the following new ones.

=head2 description

  my $description = $htaccess->description;
  $v              = $htaccess->description('Foo!');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $htaccess->usage;
  $v        = $htaccess->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS


L<Ado::Command::generate::apache2htaccess> inherits all methods from
L<Ado::Command::generate> and implements the following new ones.

=head2 run

  my $htaccess = Ado::Command::generate::apache2htaccess->run(@ARGV);
  my $htaccess = $app->commands->run("generate", "apache2htaccess",
    '-m' => 'cgi,fcgid', '-c' => $config_file);
Run this command. Returns C<$self>.

=head1 SEE ALSO

L<Ado::Plugin::Routes>,
L<Apache deployment|https://github.com/kraih/mojo/wiki/Apache-deployment>,
L<Apache - Upgrading to 2.4 from 2.2|http://httpd.apache.org/docs/2.4/upgrading.html>,
L<Ado::Command::generate::apache2vhost>,
L<Ado::Command::generate>, L<Getopt::Long>,
L<Ado::Command> L<Ado::Manual>,
L<Mojolicious>, L<Mojolicious::Guides::Cookbook/DEPLOYMENT>,
L<Mojo::Server::FastCGI>.

=cut
