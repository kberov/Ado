package Ado::Command::generate::crud;
use Mojo::Base 'Ado::Command::generate';
use Mojo::Util qw(camelize class_to_path decamelize);
use Getopt::Long qw(GetOptionsFromArray :config no_auto_abbrev no_ignore_case);
use Time::Piece ();
use List::Util qw(first);
File::Spec::Functions->import(qw(catfile catdir splitdir));

has description => "Generates directory structures for Ado-specific CRUD..\n";
has usage       => sub { shift->extract_usage };
has app         => sub { Mojo::Server->new->build_app('Ado') };

sub initialise {
    my ($self, @args) = @_;
    return $self if $self->{_initialised};
    my $args = $self->args({tables => []})->args;

    GetOptionsFromArray(
        \@args,
        'C|controller_namespace=s' => \$args->{controller_namespace},
        'd|dsn=s'                  => \$args->{dsn},
        'L|lib_root=s'             => \$args->{lib_root},
        'M|model_namespace=s'      => \$args->{model_namespace},
        'N|no_dsc_code'            => \$args->{no_dsc_code},
        'O|overwrite'              => \$args->{overwrite},
        'P|password=s'             => \$args->{password},
        'T|templates_root=s'       => \$args->{templates_root},
        't|tables=s@'              => \$args->{tables},
        'U|user=s'                 => \$args->{user},
    );

    @{$args->{tables}} = split(/\,/, join(',', @{$args->{tables}}));
    Carp::croak $self->usage unless scalar @{$args->{tables}};
    my $app = $self->app;
    $args->{controller_namespace} //= $app->routes->namespaces->[0];
    $args->{model_namespace} //=
      (first { ref($_) eq 'HASH' and $_->{name} eq 'DSC' } @{$app->config('plugins')})
      ->{config}{namespace};
    $args->{lib_root} //= 'lib';
    $args->{templates_root} = $app->renderer->paths->[0];
    $self->{_initialised}   = 1;
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
        my $c_file = catfile($args->{lib_root}, class_to_path($args->{class}));
        $args->{t} = lc $t;
        $self->render_to_rel_file('class', $c_file, $args);

        # Templates
        my $template_dir  = decamelize($class_name);
        my $template_root = (splitdir($args->{templates_root}))[-1];
        my $t_file        = catfile($template_root, $template_dir, 'list.html.ep');
        $self->render_to_rel_file('list_template', $t_file, $args);
        $t_file = catfile($template_root, $template_dir, 'create.html.ep');
        $self->render_to_rel_file('create_template', $t_file, $args);
        $t_file = catfile($template_root, $template_dir, 'read.html.ep');
        $self->render_to_rel_file('read_template', $t_file, $args);
        $t_file = catfile($template_root, $template_dir, 'delete.html.ep');
        $self->render_to_rel_file('delete_template', $t_file, $args);


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
You should have already created the tables in the database.
This tool's purpose is to promote 
L<RAD|http://en.wikipedia.org/wiki/Rapid_application_development>
and help programmers new to L<Ado> and L<Mojolicious> to quickly create
well structured, fully functional applications.

Internally this generator uses L<DBIx::Simple::Class::Schema>
to generate on the fly the classes, used to manipulate the tables' records, 
if they are not already generated. If the I<Model> classes already exist,
it creates only the controller classes and templates. 

Altough L<Ado> already have defined generic routes for CRUD, 
this command will generate more specific routes (if used through 
L<Ado::Command::generate::adoplugin>), that will secure the C<create>, 
C<update> and C<delete> actions, so they are available only to an 
authenticated user. After executing the command you should end up with a 
L<REST|http://en.wikipedia.org/wiki/REST>ful
service. The generated code uses 
L<Mojolicious::Controller/respond_to>. For details see 
L<Mojolicious::Guides::Rendering/Content-negotiation>.

In the actions you will find I<eventually working> code
for reading, creating, updating and deleting records from the tables you
specified on the command-line. The generated code uses
L<DBIx::Simple::Class>-based classes.

In addition, example code is created that uses only L<DBIx::Simple>. 
In case you prefer to use only L<DBIx::Simple> and not L<DBIx::Simple::Class>,
use the option C<'N|no_dsc_code'>. If you want pure L<DBI>, 
write the code your self.

The generated code is just boilerplate to give you a jump start, so you can
concentrate on writing your business-specific code. It is assumed that you will modify the generated code to suit your specific needs.


=head1 OPTIONS

Below are the options this command accepts, described in L<Getopt::Long> notation.


=head2 C|controller_namespace=s

Optional. The namespace for the controller classes to be generated.
Defaults to  C<app-E<gt>routes-E<gt>namespaces-E<gt>[0]>, usuallly 
L<Ado::Control>. If you decide to use another namespace for the controllers,
do not forget to add it to the list C<app-E<gt>routes-E<gt>namespaces> 
in C<etc/ado.conf> or your plugin configuration file.

=head2 d|dsn=s

Optional. Connection string parsed using L<DBI/parse_dsn> and passed to 
L<DBIx::Simple/connect>. See also L<Mojolicious::Plugin::DSC/dsn>.
By default the connection to the application database is used.

=head2 L|lib_root=s

Defaults to C<lib> relative to the current dierctory.
If you installed L<Ado> in some custom path and you wish to set it
to e.g. C<site_lib>, use this option. Do not forget to add this
directory to C<$ENV{PERL5LIB}>, so the classes can be found by C<perl>.

=head2 M|model_namespace=s

Optional. The namespace for the model classes to be generated.
Defaults to L<Ado::Model>. If you wish however to use another namespace
for another database, you will have to add another item for 
L<Mojolicious::Plugin::DSC> to the list of loaded pligins in C<etc/ado.conf>
or in your plugin configuration. Yes, multiple database connections/schemas
are supported.

=head2 N|no_dsc_code

Boolean. If this option is passed the previous option (M|model_namespace=s)
is ignored. No table classes will be generated.

=head2 O|overwrite

If there are already generated files they will be overwritten.

=head2 P|password=s

Password for the database to connect to. Needed only when C<dsn> argument is
passed and the database requires a password.

=head2 T|templates_root=s

Defaults to C<app-E<gt>renderer-E<gt>paths-E<gt>[0]>. This is usually
C<site_templates> directory. If you want to use another directory,
do not forget to add it to the C<app-E<gt>renderer-E<gt>paths> list.

=head2 t|tables=s@

Mandatory. Passing '%' would mean all the tables from the specified 
database with the C<d|dsn=s> option or the Ado database. Note that existing 
L<Ado::Model> classes will not be overwritten even if you specify C<O|overwrite>.

=head2 U|user=s

Username for the database to connect to. Needed only when C<dsn> argument is
passed and the database requires a username.

=head1 ATTRIBUTES

L<Ado::Command::generate::crud> inherits all attributes from
L<Ado::Command::generate> and implements the following new ones.

=head2 app

  $crud->app($c->app);
  my $app = $crud->app;

An instance of Ado.

=head2 description

  my $description = $command->description;
  $command        = $command->description('Foo!');

Short description of this command, used for the command list.

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

Parses arguments and prepares the command to be run. Calling this method for the second time has no effect. Returns C<$self>.

=head2 run

  $plugin->run(@ARGV);

Run this command.

=head1 TODO

Add authentication checks to update and delete actions.

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
    #TODO: add validation
    my $v = $c->validation;
    $v->required('title')->size(3, 50);
    $v->required('body')->size(3, 1 * 1024 * 1024);#1MB
    my $res;
    eval {
      $res = $table_class->create(
        id        => 3,
        title     => $v->param('title'),
        body      => $v->param('body'),
        published => 1,#not a good idea to publish right away - just for example
        user_id   => $c->user->id,
        group_id  => $c->user->group_id,
        deleted   => 0,
        permissions => '-rwxr-xr-x',
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
    return shift->render(message => '"update" is not implemented...');
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

@@ read_template
% $a = shift;
<article id="<%%= $article->{id} %>">
  <h1><%%= $article->{title} %></h1>
  <section><%%= $article->{body} %></section>
</article>

@@ update_template
% $a = shift;
<article>
  <section class="ui error form segment"><%%= $message %></section>
</article>


@@ delete_template
% $a = shift;
<article>
  <section class="ui error form segment"><%%= $message %></section>
</article>


