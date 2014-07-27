package Ado::Command::generate::adoplugin;
use Mojo::Base 'Ado::Command::generate';
use Mojo::Util qw(camelize class_to_path decamelize);
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Time::Piece ();

has description => "Generates directory structures for Ado-specific plugins..\n";
has usage => sub { shift->extract_usage };

sub run {
    my ($self, @args) = @_;
    my $args = $self->args;
    GetOptionsFromArray \@args,
      'n|name=s' => \$$args{name},
      ;

    Carp::croak $self->usage unless $$args{name};

    # Class
    my $class = $$args{name} =~ /^[a-z]/ ? camelize($$args{name}) : $$args{name};
    $class = "Ado::Plugin::$class";
    my $path = class_to_path $class;
    my $dir = join '-', split '::', $class;
    $self->render_to_rel_file('class', "$dir/lib/$path", $class, $$args{name});
    my $decamelized = decamelize($$args{name});

    # Test
    $self->render_to_rel_file('test', "$dir/t/plugin/$decamelized-00.t", $class, $$args{name});

    # Build.PL
    $self->render_to_rel_file('build_file', "$dir/Build.PL", $class, $path, $dir);

    # Configuration
    $self->render_to_rel_file('config_file', "$dir/etc/plugins/$decamelized.conf", $decamelized);

    return $self;
}
1;

=pod

=encoding utf8

=head1 NAME

Ado::Command::generate::adoplugin - Generates an Ado::Plugin

=head1 SYNOPSIS

On the command-line:

  $ bin/ado generate adoplugin --name MyBlog

Programmatically:

  use Ado::Command::generate::adoplugin;
  my $vhost = Ado::Command::generate::adoplugin->new;
  $vhost->run('--name' => 'MyBlog');

=head1 DESCRIPTION

L<Ado::Command::generate::adoplugin> generates directory structures for
fully functional L<Ado>-specific plugins.

This is a core command, that means it is always enabled and its code a good
example for learning to build new commands, you're welcome to fork it.

=head1 ATTRIBUTES

L<Ado::Command::generate::adoplugin> inherits all attributes from
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

L<Ado::Command::generate::adoplugin> inherits all methods from
L<Ado::Command> and implements the following new ones.

=head2 run

  $plugin->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Mojolicious::Command::generate::plugin>,
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
% my $decamelized = shift;
{
  # Set some configuration options for your plugin.
  foo=>'bar',
  # Add some routes.
  routes => [
    {
      route =>'/<%= $decamelized %>',via => ['GET'],
    }
  ],
  # Look in Ado and Mojolicious sources for examples.
}
