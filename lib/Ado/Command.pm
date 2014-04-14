package Ado::Command;
use Mojo::Base 'Mojolicious::Command';
use Mojo::Util qw(decamelize decode);

has args => sub { {} };
has name => sub { (ref $_[0]) =~ /(\w+)$/ && return $1 };

#default initialization for each Ado command
sub init {
    my $self = shift;
    $self->args->{do} ||= $self->name;
    $self->config->{actions} ||= [$self->name];
    return 1;
}

# Current Ado::Command home
has home => sub {

    my $class_file = Mojo::Util::class_to_path(ref($_[0]) || $_[0]);
    my ($root) = $INC{$class_file} =~ m{^(.+?)/[^/]+/$class_file$}x;
    return $root;
};

sub _get_command_config {
    my ($self) = @_;
    state $app = $self->app;
    my $name = $self->name;

    #first try (global config) !!!autovivification
    my $config = $app->config->{commands} && $app->config->{commands}->{$name};
    $config && return $config;

    #second try (command specific configuration file)
    my $conf_file = $app->home->rel_dir('/etc/commands/' . decamelize($name) . '.conf');
    if ($config = eval { Mojolicious::Plugin::Config->new->load($conf_file, {}, $app) }) {
        return $config;
    }
    else {
        $app->log->warn(
            "Could not load configuration from file $conf_file! " . decode('UTF-8', $@));
        return {};
    }
}

sub config {
    my ($self, $key) = @_;
    state $config = $self->_get_command_config();
    return $key
      ? $config->{$key}
      : $config;
}

#a default run method
sub run {
    my ($self, @args) = @_;

    #0. initialize
    $self = ref($self) ? $self : $self->new();
    $self->init(@args) || return;

    #1. run
    my $action = $self->args->{do};
    if ($action && $self->can($action)) {
        $self->$action();
    }
    else {
        Carp::croak
          "Command action '$action' was not found! Please implement it! Supported actions should be: "
          . join(', ', @{$self->config->{actions} || []});
    }

    return;
}
1;


=pod

=encoding utf8

=head1 NAME

Ado::Command - Ado namespace for Mojo commands!

=head1 DESCRIPTION

Ado::Command is the base class for eventual functionality that we 
can run directly from the commandline or from controllers.
In this class we can put common functionality shared among all the commands.

=head1 ATTRIBUTES

=head2 args

Returns a hash-reference containing all arguments passed to the command 
on the commandline or to the method L</run>.
The keys are the long variants of the possible commandline arguments 
altough you may have used short variants.

    #if you passed -s or --something
    $self->args->{something} #foo

=head2 name

The name of your command - C<(ref $self) =~ /(\w+)$/;>.

=head2 home

Returns current Ado::Command::foo home.

=head1 METHODS


=head2 init

Should be implemented by the inheriting command.

Should get options from the commandline and populate C<$self-E<gt>args>.
Must return C<$self>.

=head2 run

A default C<$command-E<gt>run(@args)> method for all Ado::Command commands.
This is the entry point to your mini application.
Looks for subcommands/actions which are looked up in
the C<--do> commands line argument and executed.
Dies with an error message advising you to implement the subcommand
if it is not found in  C<$self-E<gt>config-E<gt>{actions}>.
Override it if you want specific behavior.

    # as bin/ado alabala --do action --param1 value
    Ado::Command::alabala->run(@ARGV);
    #or from a controller
    Ado::Command::alabala->run(
      --do => action => --param1 => 'value' );

=head2 config

Returns the configuration portion specific for a command.

    #Somewhere in Ado::Command::alabala
    $self->config('username')
    #Same as $self->app->config('alabala')->{username}


=head1 SUBCOMANDS

Subcommands shared by all command classes inheriting this class.

...


=head1 SEE ALSO



=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013-2014 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

