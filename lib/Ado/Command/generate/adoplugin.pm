package Ado::Command::generate::adoplugin;
use Mojo::Base 'Ado::Command::generate';
use Mojo::Util qw(camelize class_to_path decamelize);
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Time::Piece ();
use Carp;
use Cwd;
File::Spec::Functions->import(qw(catfile catdir));


has description => "Generates directory structures for Ado-specific plugins..\n";
has usage       => sub { shift->extract_usage };
has crud        => sub {
    require Ado::Command::generate::crud;
    Ado::Command::generate::crud->new(app => shift->app);
};

sub run {
    my ($self, @args) = @_;
    my $args = $self->args;
    GetOptionsFromArray \@args,
      'n|name=s' => \$args->{name},
      'c|crud'   => \$args->{crud},

      # CRUD options
      'C|controller_namespace=s' => \$args->{controller_namespace},
      'L|lib=s'                  => \$args->{lib},
      'M|model_namespace=s'      => \$args->{model_namespace},
      'O|overwrite'              => \$args->{overwrite},
      'T|templates_root=s'       => \$args->{templates_root},
      't|tables=s@'              => \$args->{tables},
      'H|home_dir=s'             => \$args->{home_dir},
      ;

    unless ($$args{name}) {
        croak $self->usage;
    }
    if ($args->{crud} && !$args->{tables}) {
        croak 'Option --tables is mandatory when option --crud is passed!' . $/;
    }

    # Class
    my $class = $$args{name} =~ /^[a-z]/ ? camelize($$args{name}) : $$args{name};
    $class = "Ado::Plugin::$class";
    my $path = class_to_path $class;
    my $dir = join '-', split '::', $class;
    $self->render_to_rel_file('class', "$dir/lib/$path", $class, $$args{name});
    my $decamelized = decamelize($$args{name});

    if ($args->{crud}) {
        $args->{tables} = join(',', @{$args->{tables}});
        $args->{home_dir}       //= catdir(getcwd(),          $dir);
        $args->{templates_root} //= catdir($args->{home_dir}, 'templates');
        $args->{lib}            //= catdir($args->{home_dir}, 'lib');
        $self->crud->run(
            '-C' => $args->{controller_namespace},
            '-L' => $args->{lib},
            '-M' => $args->{model_namespace},
            '-O' => $args->{overwrite},
            '-T' => $args->{templates_root},
            '-t' => $args->{tables},
            '-H' => $args->{home_dir},
        );
    }

    # Test
    $self->render_to_rel_file('test', "$dir/t/plugin/$decamelized-00.t", $class, $$args{name});

    # Build.PL
    $self->render_to_rel_file('build_file', "$dir/Build.PL", $class, $path, $dir);

    # Configuration
    $self->render_to_rel_file('config_file', "$dir/etc/plugins/$decamelized.conf",
        $decamelized, $self->crud, $args);

    return $self;
}
1;

=pod

=encoding utf8

=head1 NAME

Ado::Command::generate::adoplugin - Generates an Ado::Plugin

=head1 SYNOPSIS

On the command-line:

  $ cd ~/opt/public_dev
  # Ado is "globally" installed for the current perlbrew Perl
  $ ado generate adoplugin --name MyBlog
  $ ado generate adoplugin --name MyBlog --crud -t 'articles,news'

Programmatically:

  use Ado::Command::generate::adoplugin;
  my $vhost = Ado::Command::generate::adoplugin->new;
  $vhost->run(-n => 'MyBlog', -c => 1, -t => 'articles,news');

=head1 DESCRIPTION

L<Ado::Command::generate::adoplugin> generates directory structures for
fully functional L<Ado>-specific plugins with optional 
L<MVC set of files|Ado::Command::generate::crud> in the newly created plugin directory.
The new plugin is generated in the current directory.

This is a core command, that means it is always enabled and its code a
more complex example for learning to build new commands. You're welcome to fork it.

=head1 OPTIONS

Below are the options this command accepts, described in L<Getopt::Long> notation.

=head2 n|name=s

Mandatory. String. The name of the plugin. The resulting full class name is
the camelized version of C<Ado::Plugin::$$args{name}>.

=head2 c|crud

Boolean. When set you can pass in addition all the arguments accepted by
L<Ado::Command::generate::crud>. It is mandatory to pass at least the
C<--tables> option so the controllers can be generated. 

When generating a plugin:
C<--controller_namespace>
defaults to  C<app-E<gt>routes-E<gt>namespaces-E<gt>[0]>;
C<--home_dir> defaults to the plugin base directory;
C<--lib> defaults to C<lib> in the plugin base directory;
C<--model_namespace> defaults to L<Ado::Model>;
C<--templates_root> defaults to C<templates> in the plugin base directory.

=head1 ATTRIBUTES

L<Ado::Command::generate::adoplugin> inherits all attributes from
L<Ado::Command::generate> and implements the following new ones.

=head2 crud

  #returns $self.
  $self->crud(Ado::Command::generate::crud->new(app => $self->app))
  #returns Ado::Command::generate::crud instance.
  my $crud = $self->crud->run(%options);

An instance of L<Ado::Command::generate::crud>. 
Used by L<Ado::Command::generate::adoplugin> to generate routes for controllers
and possibly others.

=head2 description

  my $description = $command->description;
  $command        = $command->description('Foo!');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $command->usage;
  $command  = $command->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Ado::Command::generate::adoplugin> inherits all methods from
L<Ado::Command> and implements the following new ones.

=head2 run

  $plugin->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious::Command::generate::plugin>,
L<Ado::Command::generate::crud>,
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


__DATA__

@@ class
% my ($class, $name) = @_;
package <%= $class %>;
use Mojo::Base 'Ado::Plugin';
our $VERSION = '0.01';

sub register {
    my ($self, $app, $config) = shift->initialise(@_);
    # Do your magic here.
    # You may want to add some helpers
    # or some new complex routes definitions,
    # or register this plugin as a template renderer.
    # Look in Mojolicious and Ado sources for examples and inspiration.
    return $self;
}

1;

<% %>__END__

<% %>=encoding utf8

<% %>=head1 NAME

<%= $class %> - an Ado Plugin that does foooooo.

<% %>=head1 SYNOPSIS

  # <%= $ENV{MOJO_HOME}%>/etc/ado.config
  plugins => {
    # other plugins here...
    '<%= $name %>',
    # other plugins here...
  }

<% %>=head1 DESCRIPTION

L<<%= $class %>> is an L<Ado> plugin.

<% %>=head1 METHODS

L<<%= $class %>> inherits all methods from
L<Ado::Plugin> and implements the following new ones.

<% %>=head2 register

  $plugin->register(Ado->new);

Register plugin in L<Ado> application.

<% %>=head1 SEE ALSO

L<Ado::Plugin>, L<Mojolicious::Guides::Growing>,
L<Ado::Manual>, L<Mojolicious>,  L<http://mojolicio.us>.

<% %>=head1 AUTHOR

Your Name

<% %>=head1 COPYRIGHT AND LICENSE

Copyright <%= Time::Piece->new->year %> Your Name.

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

<% %>=cut

@@ test
% my ($class, $name) = @_;
use Mojo::Base -strict;
use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('Ado');

my $class = '<%= $class %>';
isa_ok($class, 'Ado::Plugin');
can_ok($class, 'register');

# Add meaningfull tests here...

done_testing();

@@build_file
% my ($class, $path, $dir) = @_;
use 5.014;
use strict;
use warnings FATAL => 'all';
use Ado::BuildPlugin;

my $builder = Ado::BuildPlugin->new(
    module_name        => '<%= $class %>',
    license            => 'lgpl_3_0',
    dist_version_from  => 'lib/<%= $path %>',
    create_license     => 1,
    create_readme      => 1,
    dist_author        => q{Your Name <you@cpan.org>},
    release_status     => 'unstable',
    build_requires     => {'Test::More' => 0,},
    requires           => {Ado => '<%= Ado->VERSION %>',},
    add_to_cleanup     => ['<%= $dir %>-*', '*.bak'],
);

$builder->create_build_script();


@@config_file
% my ($decamelized, $crud, $args) = @_;

{
  # Set some configuration options for your plugin.
  foo=>'bar',
  # Add some routes.
  routes => <%= $crud->app->dumper(
    @{$crud->routes} ? $crud->routes : [{route =>"/$decamelized",via => ['GET']}]
    ); %>,
  # Look at some of the configuration files of the plugins 
  # that come with Ado for examples.
}
