package Ado::Command::generate::crud;
use Mojo::Base 'Ado::Command::generate';
use Mojo::Util qw(camelize class_to_path decamelize);
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Time::Piece ();
use List::Util qw(first);
File::Spec::Functions->import(qw(catfile catdir splitdir));

has description => "Generates directory structures for Ado-specific CRUD..\n";
has usage => sub { shift->extract_usage };

has routes => sub {
    $_[0]->{routes} = [];
    foreach my $t (@{$_[0]->args->{tables}}) {
        my $controller = camelize($t);
        my $route      = decamelize($controller);
        push @{$_[0]->{routes}},
          { route => "/$route",
            via   => ['GET'],
            to    => "$route#list",
          },
          { route => "/$route/list",
            via   => ['GET'],
            to    => "$route#list",
          },
          { route => "/$route/read/:id",
            via   => [qw(GET)],
            to    => "$route#read",
          },
          { route => "/$route/create",
            via   => [qw(GET POST)],
            to    => "$route#create",
            over  => {authenticated => 1},
          },
          { route => "/$route/update/:id",
            via   => [qw(GET PUT)],
            to    => "$route#update",
            over  => {authenticated => 1},
          },
          { route => "/$route/delete/:id",
            via   => [qw(GET DELETE)],
            to    => "$route#delete",
            over  => {authenticated => 1},
          };
    }
    return $_[0]->{routes};
};

sub initialise {
    my ($self, @args) = @_;
    return $self if $self->{_initialised};
    my $args = $self->args({tables => []})->args;

    GetOptionsFromArray(
        \@args,
        'C|controller_namespace=s' => \$args->{controller_namespace},

        #'d|dsn=s'                  => \$args->{dsn},
        'L|lib=s'             => \$args->{lib},
        'M|model_namespace=s' => \$args->{model_namespace},

        #'N|no_dsc_code'            => \$args->{no_dsc_code},
        'O|overwrite' => \$args->{overwrite},

        #'P|password=s'             => \$args->{password},
        'T|templates_root=s' => \$args->{templates_root},
        't|tables=s@'        => \$args->{tables},
        'H|home_dir=s'       => \$args->{home_dir},

        #'U|user=s'                 => \$args->{user},
    );

    @{$args->{tables}} = split(/\,/, join(',', @{$args->{tables}}));
    Carp::croak $self->usage unless scalar @{$args->{tables}};
    my $app = $self->app;
    $args->{controller_namespace} //= $app->routes->namespaces->[0];
    $args->{model_namespace} //=
      (first { ref($_) eq 'HASH' and $_->{name} eq 'DSC' } @{$app->config('plugins')})
      ->{config}{namespace};
    $args->{home_dir}       //= $app->home;
    $args->{lib}            //= catdir($args->{home_dir}, 'lib');
    $args->{templates_root} //= $app->renderer->paths->[0];
    $self->{_initialised} = 1;
    return $self;
}

sub run {
    my ($self) = shift->initialise(@_);
    my $args   = $self->args;
    my $app    = $self->app;

    foreach my $t (@{$args->{tables}}) {

        # Controllers
        my $class_name = camelize($t);
        $args->{class} = $args->{controller_namespace} . '::' . $class_name;
        my $c_file = catfile($args->{lib}, class_to_path($args->{class}));
        $args->{t} = lc $t;
        $self->render_to_file('class', $c_file, $args);

        # Templates
        my $template_dir  = decamelize($class_name);
        my $template_root = $args->{templates_root};
        my $t_file        = catfile($template_root, $template_dir, 'list.html.ep');
        $self->render_to_file('list_template', $t_file, $args);
        $t_file = catfile($template_root, $template_dir, 'create.html.ep');
        $self->render_to_file('create_template', $t_file, $args);
        $t_file = catfile($template_root, $template_dir, 'read.html.ep');
        $self->render_to_file('read_template', $t_file, $args);
        $t_file = catfile($template_root, $template_dir, 'delete.html.ep');
        $self->render_to_file('delete_template', $t_file, $args);
    }    # end foreach tables

    return $self;
}


1;


=pod

=encoding utf8

=head1 NAME

Ado::Command::generate::crud - Generates MVC set of files

=head1 SYNOPSIS

  Usage:
  #on the command-line
  # for one or more tables.
  $ bin/ado generate crud --tables='news,articles'

  #programatically
  use Ado::Command::generate::crud;
  my $v = Ado::Command::generate::crud->new;
  $v->run(-t => 'news,articles');

=head1 DESCRIPTION

B<Disclaimer: I<This command is highly experimental!>
The generated code is not even expected to work properly.>

L<Ado::Command::generate::crud> generates directory structure for
a fully functional
L<MVC|http://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller>
set of files, based on existing tables in the database.
You only need to create the tables. The Model (M) classes are generated on the fly
from the tables when the controller classes are loaded by L<Ado> for the first time.
You can dump them to disk if you want using the C<dsc_dump_schema.pl> script that
comes with L<DBIx::Simple::Class>. You may decide to use only L<DBIx::Simple>
via the C<$c-E<gt>dbix> helper or L<DBI> via C<$c-E<gt>dbix-E<gt>dbh>.
That's up to you.

This tool's purpose is to promote
L<RAD|http://en.wikipedia.org/wiki/Rapid_application_development>
by generating the boilerplate code for controllers (C)
and help programmers new to L<Ado> and L<Mojolicious> to quickly create
well structured, fully functional applications.

In the generated actions you will find I<eventually working> code
for reading, creating, updating and deleting records from the tables you
specified on the command-line.

The generated code is just boilerplate to give you a jump start, so you can
concentrate on writing your business-specific code. It is assumed that you will
modify the generated code to suit your specific needs.

=head1 OPTIONS

Below are the options this command accepts, described in L<Getopt::Long> notation.

=head2 C|controller_namespace=s

Optional. The namespace for the controller classes to be generated.
Defaults to  C<app-E<gt>routes-E<gt>namespaces-E<gt>[0]>, usually
L<Ado::Control>. If you decide to use another namespace for the controllers,
do not forget to add it to the list C<app-E<gt>routes-E<gt>namespaces>
in C<etc/ado.conf> or your plugin configuration file.

=head2 H|home_dir=s

Defaults to C<$ENV{MOJO_HOME}> (which is Ado home directory).
Used to set the root directory to which the files
will be dumped when L<generating an Ado plugin|Ado::Command::generate::adoplugin>.

=head2 L|lib=s

Defaults to C<lib> relative to the C<--home_dir> directory.
If you installed L<Ado> in some custom path and you wish to generate your controllers into
e.g. C<site_lib>, use this option. Do not forget to add this
directory to C<$ENV{PERL5LIB}>, so the classes can be found and loaded.

=head2 M|model_namespace=s

Optional. The namespace for the model classes to be generated.
Defaults to L<Ado::Model>. If you wish however to use another namespace
for another database, you will have to add another item for
L<Mojolicious::Plugin::DSC> to the list of loaded plugins in C<etc/ado.conf>
or in your plugin configuration. Yes, multiple database connections/schemas
are supported.

=head2 T|templates_root=s

Defaults to C<app-E<gt>renderer-E<gt>paths-E<gt>[0]>. This is usually
C<site_templates> directory. If you want to use another directory,
do not forget to add it to the C<app-E<gt>renderer-E<gt>paths> list
in your configuration file.

=head2 t|tables=s@

Mandatory. List of tables separated by commas for which controllers should be generated.

=head1 ATTRIBUTES

L<Ado::Command::generate::crud> inherits all attributes from
L<Ado::Command::generate> and implements the following new ones.

=head2 description

  my $description = $command->description;
  $command        = $command->description('Foo!');

Short description of this command, used for the command list.

=head2 routes

  $self->routtes();

Returns an ARRAY reference containing routes, prepared after C<$self-E<gt>args-E<gt>{tables}>.

Altough L<Ado> already has defined generic routes for CRUD,
this attribute contains more specific routes, that will secure the C<create>,
C<update> and C<delete> actions, so they are available only to an
authenticated user. This attribute is used for generating routes in
L<Ado::Command::generate::adoplugin>.
After generating a plugin you should end up with a
L<RESTful|http://en.wikipedia.org/wiki/REST>
service. The generated code uses
L<Mojolicious::Controller/respond_to>. For details see
L<Mojolicious::Guides::Rendering/Content-negotiation>.

=head2 usage

  my $usage = $command->usage;
  $command  = $command->usage('Foo!');

Usage information for this command, used for the help screen.

=head1 METHODS

L<Ado::Command::generate::crud> inherits all methods from
L<Ado::Command> and implements the following new ones.

=head2 initialise

  sub run {
      my ($self) = shift->initialise(@_);
      #...
  }

Parses arguments and prepares the command to be run. Calling this method for the second time has no effect.
Returns C<$self>.

=head2 run

  Ado::Command::generate::crud->new(app=>$app)->run(@ARGV);

Run this command.

=head1 SEE ALSO

L<Ado::Command::generate::adoplugin>,
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
% my $a = shift;
package <%= $a->{class} %>;
use Mojo::Base '<%= $a->{controller_namespace} %>';

our $VERSION = '0.01';

# Generate class on the fly from the database.
# No worries - this is cheap, one-time generation.
# See documentation for Ado::Model::class_from_table
my $table_class = Ado::Model->table_to_class(
  namespace => '<%= $a->{model_namespace} %>',
  table     => '<%= $a->{t} %>',
  type      => 'TABLE'
);

# List resourses from table <%= $a->{t} %>.
sub list {
    my $c = shift;
    $c->require_formats('json','html') || return;
    my $args = Params::Check::check(
        {   limit => {
                allow => sub { $_[0] =~ /^\d+$/ ? 1 : ($_[0] = 20); }
            },
            offset => {
                allow => sub { $_[0] =~ /^\d+$/ ? 1 : defined($_[0] = 0); }
            },
        },
        {   limit  => $c->req->param('limit')  || 20,
            offset => $c->req->param('offset') || 0,
        }
    );

    $c->res->headers->content_range(
        "<%= $a->{t} %> $$args{offset}-${\($$args{limit} + $$args{offset})}/*");
    $c->debug("rendering json and html only [$$args{limit}, $$args{offset}]");

    #Used in template <%= $a->{t}%>/list.html.ep
    $c->stash('table_class',$table_class);
    #content negotiation
    my $list = $c->list_for_json(
            [$$args{limit}, $$args{offset}],
            [$table_class->select_range($$args{limit}, $$args{offset})]
        );
    return $c->respond_to(
        json => $list,
        html =>{list =>$list}
    );
}

# Creates a resource in table <%= $a->{t} %>. A naive example.
sub create {
    my $c = shift;
    my $v = $c->validation;
    return $c->render unless $v->has_data;

    $v->required('title')->size(3, 50);
    $v->required('body')->size(3, 1 * 1024 * 1024);#1MB
    my $res;
    eval {
      $res = $table_class->create(
        title     => $v->param('title'),
        body      => $v->param('body'),
        user_id   => $c->user->id,
        group_id  => $c->user->group_id,
        deleted   => 0,
        #permissions => '-rwxr-xr-x',
        );
    }||$c->stash(error=>$@);#very rude!!!
        $c->debug('$error:'.$c->stash('error')) if $c->stash('error');

    my $data = $res->data;

    return $c->respond_to(
        json => {data => $data},
        html => {data => $data}
    );
}

# Reads a resource from table <%= $a->{t} %>. A naive example.
sub read {
    my $c = shift;
    #This could be validated by a stricter route
    my ($id) = $c->stash('id') =~/(\d+)/;

    my $data = $table_class->find($id)->data;
    $c->debug('$data:'.$c->dumper($data));
    return $c->respond_to(
        json => {article => $data},
        html => {article => $data}
    );
}

# Updates a resource in table <%= $a->{t} %>.
sub update {
    my $c = shift;
    my $v = $c->validation;
    my ($id) = $c->stash('id') =~/(\d+)/;
    my $res = $table_class->find($id);
    $c->reply->not_found() unless $res->data;
    $c->debug('$data:'.$c->dumper($res->data));

    if($v->has_data && $res->data){
        $v->optional('title')->size(3, 50);
        $v->optional('body')->size(3, 1 * 1024 * 1024);#1MB
        $res->title($v->param('title'))->body($v->param('body'))
         ->update() unless $v->has_error;
    }
    my $data = $res->data;
    return $c->respond_to(
        json => {article => $data},
        html => {article => $data}
    );
}

# "Deletes" a resource from table <%= $a->{t} %>.
sub delete {
    return shift->render(message => '"delete" is not implemented...');
}



1;

<% %>__END__

<% %>=encoding utf8

<% %>=head1 NAME

<%= $a->{class} %> - a controller for resource <%= $a->{t} %>.

<% %>=head1 SYNOPSIS







<% %>=cut



@@ list_template
% $a = shift;
%% my $columns = $table_class->COLUMNS;
<table>
  <thead>
    <tr>
    %% foreach my $column( @$columns ){
      <th><%%= $column %></th>
    %% }
    </tr>
  </thead>
  <tbody>
    %% foreach my $row (@{$list->{json}{data}}) {
    <tr>
      %% foreach my $column( @$columns ){
      <td><%%= $row->{$column} %></td>
      %% }
    </tr>
    %% }
  </tbody>
    %%#== $c->dumper($list);
</table>

@@ create_template
% $a = shift;
<article>
  Create your form for creating a resource here.
</article>

@@ read_template
% $a = shift;
<article id="<%%= $article->{id} %>">
  <h1><%%= $article->{title} %></h1>
  <section><%%= $article->{body} %></section>
</article>

@@ update_template
% $a = shift;
<article>
  Create your form for updating a resource here.
</article>


@@ delete_template
% $a = shift;
<article>
  <section class="ui error form segment"><%%= $message %></section>
</article>


