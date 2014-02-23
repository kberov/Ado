package Ado;

use Mojo::Base 'Mojolicious';
use File::Spec::Functions qw(splitdir catdir catfile);

BEGIN {
    return if $ENV{MOJO_HOME};
    my @home = splitdir File::Basename::dirname(__FILE__);
    while (pop @home) {
        $ENV{MOJO_HOME} ||= catdir(@home) if -s catfile(@home, 'bin', 'ado');
    }
}
our $AUTHORITY = 'cpan:BEROV';
our $VERSION   = '0.34';
our $CODENAME  = 'U+2C01 Главна буква БУКИ от Глаголицата (Ⰱ)';

use Ado::Control;
use Ado::Sessions;

sub CODENAME { return $CODENAME }
has sessions => sub { Ado::Sessions::get_instance(shift->config) };

# This method will run once at server start
sub startup {
    my $app = shift;
    $app->load_config()->load_plugins()->load_routes()->define_hooks();
    return;
}

#load ado.conf
sub load_config {
    my $app = shift;
    $ENV{MOJO_CONFIG} ||= catfile($ENV{MOJO_HOME}, 'etc', 'ado.conf');
    $app->plugin('Config');
    return $app;
}

sub load_plugins {
    my $app = shift;

    # Documentation browser under "/perldoc"
    $app->plugin('PODRenderer', {no_perldoc => 1});

    #HACK!
    #TODO: Inherit PODRenderer and implement an Ado Default perldoc plugin.
    my $defaults = {module => 'Ado/Manual', format => 'html'};
    ##no critic (ProtectPrivateSubs,ProhibitUnusedPrivateSubroutines,ProtectPrivateVars)
    $app->routes->any('/perldoc/:module' => $defaults => [module => qr/[^.]+/] =>
          \&Mojolicious::Plugin::PODRenderer::_perldoc);

    my $plugins = $app->config('plugins') || [];
    foreach my $plugin (@$plugins) {
        $app->log->debug('Loading Plugin:' . $app->dumper($plugin));
        if (ref $plugin eq 'HASH') {
            $app->plugin($plugin->{name} => $plugin->{config});
        }
        elsif ($plugin) {
            $app->plugin($plugin);
        }
    }
    return $app;
}

#load routes defined in ado.conf
sub load_routes {
    my ($app, $config_routes) = @_;
    $config_routes ||= $app->config('routes') || [];
    my $routes = $app->routes;

    #hide Ado::Control methods and attributes
    $routes->hide(
        qw(
          debug config require_format list_for_json
          validate_input
          )
    );

    foreach my $route (@$config_routes) {
        my ($pattern, $over, $to, $via, $params) =
          ($route->{route}, $route->{over}, $route->{to}, $route->{via}, $route->{params});

        next unless $to;
        my $r = $params ? $routes->route($pattern, %$params) : $routes->route($pattern);

        if ($over) {
            if    (ref $over eq 'ARRAY') { $r->over(@$over); }
            elsif (ref $over eq 'HASH')  { $r->over(%$over); }
            else                         { $r->over($over); }
        }
        if ($via) {
            $r->via(@$via);
        }
        $r->to(ref $to eq 'HASH' ? %$to : $to);
        $app->log->debug('load_routes: name:' . $r->name . '; pattern:' . $r->to_string);
    }

    return $app;
}

sub define_hooks {
    my $app = shift;
    return $app;
}

1;


=pod

=encoding utf8

=head1 NAME

Ado - busy or delaying activity; bustle; fuss. 


=head1 SYNOPSIS

  require Mojolicious::Commands;
  Mojolicious::Commands->start_app('Ado');

=head1 ATTRIBUTES

Ado inherits all attributes from Mojolicious and implements the following ones.

=head2 CODENAME

Returns the current C<CODENAME>.

=head2 sessions

Access the Ado sessions instance.

=head1 METHODS

Ado inherits all methods from Mojolicious and implements 
the following new ones.

=head2 startup

The startup method is where everything begins. Return $apps void.

=head2 load_config

Loads the configuration file C<$app-E<gt>home/etc/ado.conf>.
Returns $app.

=head2 load_plugins

Loads plugins listed in C<$config-E<gt>{plugins}>.
This is an C<ARRAYREF> in which each element is a C<HASHREF> with
keys C<name> and C<config>.
The name of the plugin is expected to be string that can be passed to
L<Mojolicious/plugin>.
The C<config> values is another C<HASHREF> containing the configuration for the plugin.
Plugins can be Mojolicious or Ado specific plugins.
Every L<Ado::Plugin>::Foo must inherit from L<Ado::Plugin> which C<ISA>
L<Mojolicious::Plugin>.
Of course Mojolicious plugins can be used - we count on this.
There are plenty of examples on CPAN.
Returns $app.

=head2 load_routes

Loads predefined routes from C<$config-E<gt>routes>.
This is an C<ARRAYREF> in which each element is a C<HASHREF> with
keys corresponding to a method name and value the parameters that 
will be passed tot he method. Currently we use the C<route> value to pass it
to L<Mojolicious::Routes/route>,C<params> value is the second parameter to instantiate the route. C<via> and C<to> values are passed 
to the newly created route. 
See L<Mojolicious::Routes::Route> and L<Mojolicious::Guides::Routing> for more.

Returns $app.

=head2 define_hooks

Defines some hooks to intervene in the default workflow of the requests.
Returns $app.

=head1 SPONSORS

The original author

=head1 SEE ALSO

L<Mojolicious>, L<Ado::Manual>,
L<http://www.thefreedictionary.com/ado>, 


=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut

