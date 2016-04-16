package Ado::Plugin::AdoHelpers;
use Mojo::Base 'Ado::Plugin';
use Mojo::Util qw(slurp decode);
use List::Util qw(first);

# allow plugins to process SQL scripts while loading
sub do_sql_file {
    my ($app, $sql_file) = @_;
    my $dbh = $app->dbix->dbh;

    #$app->log->debug('do_sql_file:' . $sql_file) if $Ado::Control::DEV_MODE;

    my $SQL = decode('UTF-8', slurp($sql_file));

    #Remove multi-line comments
    $SQL =~ s|/\*+.+?\*/\s+?||gsmx;

    #$app->log->debug('$SQL:' . $SQL) if $Ado::Control::DEV_MODE;
    local $dbh->{RaiseError} = 1;
    my $last_statement = '';
    return eval {
        $dbh->begin_work;
        for my $st (split /;/smx, $SQL) {
            $last_statement = $st;
            $dbh->do($st) if ($st =~ /\S+/smx);
        }
        $dbh->commit;
    } || do {
        my $e = "\nError in statement:$last_statement\n$@";
        my $e2;
        eval { $dbh->rollback } || ($e2 = $/ . 'Additionally we have a rollback error:' . $@);
        $app->log->error($e . ($e2 ? $e2 : ''));
        Carp::croak($e . ($e2 ? $e2 : ''));
    };
}

sub register {
    my ($self, $app, $conf) = shift->initialise(@_);

    # Add helpers
    $app->helper(user => sub { shift->user(@_) });

    # http://irclog.perlgeek.de/mojo/2014-10-03#i_9453021
    $app->helper(to_json => sub { Mojo::JSON::to_json($_[1]) });
    Mojo::Util::monkey_patch(ref($app), do_sql_file => \&Ado::Plugin::AdoHelpers::do_sql_file);

    $app->helper('head_css'        => \&_head_css);
    $app->helper('head_javascript' => \&_head_javascript);

    return $self;
}    #end of register

my $file_re = qr/\w+\.\w+(\?.*)?$/;

sub _head_css {
    my ($c, $assets) = @_;
    my $assets_list = $c->stash('head_css');

    #append
    if ($assets) {
        $assets = [$assets] unless ref($assets) eq 'ARRAY';
        foreach my $a (@$assets) {
            push @$assets_list, $a unless first { $_ eq $a } @$assets_list;
        }
        return;
    }

    # render
    my $css = '';

    #everything in separate stylesheet begin end block or <link>
    foreach my $a (@$assets_list) {
        if ($a =~ $file_re) {    # a file
            $css .= qq|<link href="$a" rel='stylesheet' type='text/css' />\n|;
        }
        elsif (ref $a eq 'CODE') {    # a code
            $css .= $c->stylesheet($a) . $/;
        }
        else {                        # a string
            $css .= $c->stylesheet(sub {$a}) . $/;
        }
    }
    return $css;
}

sub _head_javascript {
    my ($c, $assets) = @_;
    my $assets_list = $c->stash('head_javascript');

    #append
    if ($assets) {
        $assets = [$assets] unless ref($assets) eq 'ARRAY';
        foreach my $a (@$assets) {
            push @$assets_list, $a unless first { $_ eq $a } @$assets_list;
        }
        return;
    }

    # render
    my $js = '';

    #everything in separate javascript begin/end block or <script>
    foreach my $a (@$assets_list) {
        if ($a =~ $file_re) {    # a file
            $js .= qq|<script src="$a"></script>\n|;
        }
        elsif (ref $a eq 'CODE') {    # a code
            $js .= $c->javascript($a) . $/;
        }
        else {                        # a string
            $js .= $c->javascript(sub {$a}) . $/;
        }
    }
    return $js;

}

1;

=encoding utf8

=head1 NAME

Ado::Plugin::AdoHelpers - Default Ado helpers plugin

=head1 SYNOPSIS

  # Ado
  $self->plugin('AdoHelpers');

  # Mojolicious::Lite
  plugin 'AdoHelpers';

=head1 DESCRIPTION

L<Ado::Plugin::AdoHelpers> is a collection of renderer helpers for
L<Ado>.

This is a core plugin, that means it is always enabled and its code a good
example for learning to build new plugins, you're welcome to fork it.

See L<Ado::Manual::Plugins/PLUGINS> for a list of plugins that are available
by default.

=head1 HELPERS

L<Ado::Plugin::AdoHelpers> implements the following helpers.

=head2 do_sql_file

Your plugin may need to add some new tables, add columns to already
existing tables or insert some data. This method allows you to do that.
See the source code of L<Ado::Plugin::Vest> for example.
The SQL file will be slurped, multiline comments will be removed.
The content will be split into C<';'> and each statement will be executed
using L<DBI/do>.

  # in a plugin somewhere in register
  $app->do_sql_file(catfile($self->config_dir, $sql_file));
  $app->do_sql_file($conf->{vest_data_sql_file});

  # on the command line
  $ ado eval 'app->do_sql_file(shift)' some_file.sql

  # elsewhere in an application
  $app->do_sql_file($sql_file)

=head2 head_css, head_javascript

Minimalist asset management for the C<E<lt>headE<gt>> section. Appends and
later renders assets (links to files and code-snippets) to
C<$c-E<gt>stash('head_css')> and C<app-E<gt>stash('head_javascript')>. The new
assets are only appended if they are not already present in the corresponding
list of assets. The defaults are populated in C<etc/ado.conf>. See also:
L<Mojolicious/defaults>; L<Mojolicious::Plugin::AssetPack>.

  #in a template:
  #append
  <%
    head_css([
      'vendor/SemanticUI/components/popup.min.css'
      '#myid { font-size:xx-small }'
    ]);
    head_javascript([
      'vendor/SemanticUI/components/popup.min.js'
      'jQuery( function($){ $('#ado-img').popup() })'
    ]);
  %>
  <!-- or -->
      # or
  % head_javascript begin
      jQuery( function($){ $('#ado-img').popup() });
  % end;

  # render in templates/partials/head.html.ep
  %== head_css; 
  <link href="css/ado.css" rel='stylesheet' type='text/css' />
  <link href='//fonts.googleapis.com/css?family=Ubuntu&amp;subset=latin,cyrillic'
    rel='stylesheet' type='text/css' />
  %== head_javascript;

=head2 to_json

Suitable for preparing JavaScript
objects from Perl references that will be used from stash and in templates.

  my $chars = $c->to_json({name =>'Петър',id=>2});
  $c->stash(user_as_js => $chars);
  # in a javascript chunk of a template
  var user = <%== $user_as_js %>;
  var user_group_names = <%== to_json([user->ingroup]) %>;

=head2 user

Returns the current user. This is the user C<guest> for not authenticated users.
This helper is a wrapper for L<Ado::Control/user>.

  $c->user(Ado::Model::Users->query("SELECT * from users WHERE login_name='guest'"));
  #in a controller action:
  my $current_user = $c->user;
  #in a template:
  <h1>Hello, <%=user->name%>!</h1>

=head1 METHODS

L<Ado::Plugin::AdoHelpers> inherits all methods from
L<Ado::Plugin> and implements the following new ones.

=head2 register

  $plugin->register(Ado->new);

Register helpers in L<Ado> application.

=head1 SEE ALSO

L<Ado::Plugin>, L<Mojolicious::Plugins>, L<Mojolicious::Plugin>, 


=head1 AUTHOR

Красимир Беров (Krasimir Berov)

=head1 COPYRIGHT AND LICENSE

Copyright 2013-2015 Красимир Беров (Krasimir Berov).

This program is free software, you can redistribute it and/or
modify it under the terms of the 
GNU Lesser General Public License v3 (LGPL-3.0).
You may copy, distribute and modify the software provided that 
modifications are open source. However, software that includes 
the license may release under a different license.

See http://opensource.org/licenses/lgpl-3.0.html for more information.

=cut
