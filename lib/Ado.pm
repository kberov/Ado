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
our $VERSION   = '0.59';
our $CODENAME  = 'U+2C05 GLAGOLITIC CAPITAL LETTER YESTU (Ⰵ)';

use Ado::Control;
use Ado::Sessions;

sub CODENAME { return $CODENAME }
has sessions => sub { Ado::Sessions::get_instance(shift->config) };

# This method will run once at server start
sub startup {
    my $app = shift;
    $app->load_config()->load_plugins()->load_routes()->define_mime_types();
    return;
}

#load ado.conf
sub load_config {
    my $app = shift;
    $ENV{MOJO_CONFIG} ||= catfile($app->home, 'etc', 'ado.conf');
    $app->plugin('Config');
    return $app;
}

sub load_plugins {
    my $app = shift;

    my $plugins = $app->config('plugins') || [];
    foreach my $plugin (@$plugins) {
        $app->log->debug(
            'Loading Plugin:' . (ref $plugin ? $app->dumper($plugin) : "$plugin..."));
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

    # Hide Ado::Control methods and attributes from router.
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
            if   (ref $over eq 'HASH') { $r->over(%$over); }
            else                       { $r->over($over); }
        }
        if ($via) {
            $r->via(@$via);
        }
        $r->to(ref $to eq 'HASH' ? %$to : $to);
        $app->log->debug('load_routes: name:' . $r->name . '; pattern: "' . $r->to_string . '"');
    }

    # Default "/perldoc" page is Ado/Manual
    my $perldoc = $routes->lookup('perldocmodule');
    if ($perldoc) { $perldoc->to->{module} = 'Ado/Manual'; }

    return $app;
}

sub define_mime_types {
    my $app = shift;
    my $mimes = $app->config('types') || {};    #HASHREF
    foreach my $mime (keys %$mimes) {

        # Add new MIME type or redefine any existing
        $app->types->type($mime => $mimes->{$mime});
    }
    return $app;
}

1;


=pod

=encoding utf8

=head1 NAME

Ado - a rapid active commotion (framework for web-projects on Mojolicious)

=head1 SYNOPSIS

  require Mojolicious::Commands;
  Mojolicious::Commands->start_app('Ado');

=head1 DESCRIPTION

L<Ado> is a framework for web-projects based on L<Mojolicious>,
written in the L<Perl programming language|http://www.perl.org/>.
This is the base application class. Ado C<ISA> L<Mojolicious>.
For a more detailed description on how to get started with Ado see L<Ado::Manual>.

=head1 ATTRIBUTES

Ado inherits all attributes from Mojolicious and implements the following ones.

=head2 CODENAME

Returns the current C<CODENAME>.

=head2 sessions

Access the L<Ado::Sessions> instance. Instantiates one of
L<Ado::Sessions::File>, L<Ado::Sessions::Database>
or L<Mojolicious::Sessions> depending on configuration and returns it.
By default (no configuration in C<etc/ado.conf>)
a L<Mojolicious::Sessions> is returned.


=head1 METHODS

Ado inherits all methods from Mojolicious and implements
the following new ones.

=head2 startup

The startup method is where everything begins. Returns void.
The following methods are listed in the order they are invoked in L</startup>.

=head2 load_config

Loads the configuration file C<$app-E<gt>home/etc/ado.conf>.
Returns $app.

=head2 load_plugins

Does not accept any parameters.
Loads plugins listed in C<$config-E<gt>{plugins}>.
C<$config-E<gt>{plugins}> is an C<ARRAYREF> in which each element is
a C<HASHREF> with keys C<name> and C<config> or string representing the plugin name.
The name of the plugin is expected to be string that can be passed to
L<Mojolicious/plugin>.
The C<config> values is another C<HASHREF> containing the configuration for the plugin.
Plugins can be L<Mojolicious> or L<Ado> specific plugins.
Every L<Ado::Plugin>::Foo must inherit from L<Ado::Plugin> which C<ISA>
L<Mojolicious::Plugin>.
Of course Mojolicious plugins can be used - we count on this.
There are plenty of examples on CPAN.
Returns $app.

=head2 load_routes

Does not accept any parameters.
Loads predefined routes from C<$config-E<gt>routes>.
C<$config-E<gt>routes> is an C<ARRAYREF> in which each element is a C<HASHREF> with
keys corresponding to a method name and value the parameters that
will be passed to the method. Currently we use the C<route> value to pass it
to L<Mojolicious::Routes/route>,C<params> value is the second parameter to
instantiate the route. C<via> and C<to> values are passed 
to the newly created route.
See L<Mojolicious::Routes::Route> and L<Mojolicious::Guides::Routing> for more.

Returns $app.

=head2 define_mime_types

Defines any MIME types listed in C<ado.conf> in C<types =E<gt> {...}>.
Returns $app.

=head1 SPONSORS

The original author.

Become a sponsor and help make L<Ado> the ERP for the enterprise!

=head1 SEE ALSO

L<Mojolicious>, L<Ado::Manual>,
L<http://www.thefreedictionary.com/ado>,

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
