package Ado::Control;
use Mojo::Base 'Mojolicious::Controller';

our $DEV_MODE = ($ENV{MOJO_MODE} || '' =~ /dev/);
has description => 'Ado is a framework for web projects based on Mojolicious,'
  . ' written in the Perl programming language.';
has keywords => 'SSOT, CRM, ERP, CMS, Perl, SQL';

sub generator { return 'Ado ' . $Ado::VERSION . ' - ' . $Ado::CODENAME }

sub config {
    my ($c, $key) = @_;
    state $app = $c->app;
    return $app->config(ref $c)->{$key} if $key;
    return $app->config(ref $c);
}

sub debug;
if ($DEV_MODE) {

    sub debug {
        my ($package, $filename, $line, $subroutine) = caller(1);
        return shift->app->log->debug(@_, "$package:$filename:$line in $subroutine");
    }
}

#Require a  list of formats or render "415 - Unsupported Media Type"
#and return false.
sub require_formats {
    my ($c, @formats) = @_;
    unless ($c->accepts(@formats)) {

        #propose urls with the accepted formats
        my @locations = map { $c->url_for(format => $_)->to_abs } @formats;
        $c->res->headers->add('Content-Location' => $locations[0]);

        my $message =
            "415 - Unsupported Media Type \""
          . ($c->req->headers->accept // '')
          . "\". Please try ${\ join(', ', @locations)}!";
        $c->debug($c->url_for . " requires " . join(',', @formats) . ". Rendering: $message")
          if $DEV_MODE;
        $c->render(
            text   => $message,
            status => 415
        );
        return;
    }
    return 1;
}

sub list_for_json {
    my ($c, $range, $dsc_objects) = @_;
    my $url = $c->url_with(format => $c->stash->{format})->query('limit' => $$range[0]);
    my $prev = $$range[1] - $$range[0];
    $prev = $prev > 0 ? $prev : 0;

    #arrayref of hashes or DSC objects?
    my $data =
      ref($dsc_objects->[0]) eq 'HASH'
      ? $dsc_objects
      : [map { $_->data } @$dsc_objects];
    return {
        json => {

            #TODO: Strive to implement linking using this reference:
            # http://www.iana.org/assignments/link-relations/link-relations.xhtml
            links => [
                {   rel  => 'self',
                    href => "" . $url->query([offset => $$range[1]])
                },
                (   @$data == $$range[0]
                    ? { rel  => 'next',
                        href => "" . $url->query([offset => $$range[0] + $$range[1]])
                      }
                    : ()
                ),
                (   $$range[1]
                    ? { rel  => 'prev',
                        href => "" . $url->query([offset => $prev])
                      }
                    : ()
                ),
            ],
            data => $data
        },
    };
}    # end sub list_for_json

#validates input parameters given a rules template
sub validate_input {
    my ($c, $template) = @_;
    my $v      = $c->validation;
    my $errors = {};
    foreach my $param (keys %$template) {
        my $checks = $template->{$param};
        $checks || next;    #false or undefined?!?

        #field
        my $f =
            $checks->{required}
          ? $v->required($param)
          : $v->optional($param);
        foreach my $check (keys %$checks) {
            next if $check eq 'required';
            if (ref $$checks{$check} eq 'HASH') {
                $f->$check(%{$checks->{$check}});
            }
            elsif (ref $$checks{$check} eq 'ARRAY') {
                $f->$check(@{$checks->{$check}});
            }
            else { $f->$check($checks->{$check}) }
        }    #end foreach my $check
        $errors->{$param} = $f->error($param)
          if $f->error($param);

    }    #end foreach my $param

    return {
        (   !!keys %{$errors}
            ? ( errors => $errors,
                json   => {
                    status  => 'error',
                    code    => 400,
                    message => $errors,
                    data    => 'validate_input'
                }
              )
            : (output => $v->output)
        )
    };
}

sub user {
    my ($c, $user) = @_;
    state $delete_fields = [qw(login_password created_by changed_by disabled start_date email)];
    if ($user) {

        # Remove as much as possible user data.
        delete @{$user->data}{@$delete_fields};
        $c->{user} = $user;
        return $c;
    }
    elsif ($c->{user}) {
        return $c->{user};
    }

    # Called for the first time without a $user object.
    # Defaults to current user or Guest.
    $c->{user} = Ado::Model::Users->by_login_name($c->session->{login_name} //= 'guest');
    delete @{$c->{user}->data}{@$delete_fields};
    return $c->{user};
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Control - The base class for all controllers!

=head1 SYNOPSIS

It must be inherited by all controllers.
Put code here only to be shared by it's subclasses or used in hooks.

  package Ado::Control::Hello;
  use Mojo::Base 'Ado::Control';

=head1 ATTRIBUTES

Ado::Control inherits all attributes from L<Mojolicious::Controller> 
and implements the following new ones.

=head2 description

Returns a default description used in C<head> element of HTML pages.

=head2 generator

Returns the concatenated moniker, VERSION and L<CODENAME>.

=head2 keywords

Returns default keywords used in C<head> element of HTML pages.

=head1 SUBROUTINES/METHODS

Methods shared among subclasses and in hooks

=head2 config

Overwrites the default helper L<Mojolicious::Plugin::DefaultHelpers/config>
which is actually an alias for L<Mojo/config>.
Returns configuration specific to the I<current controller> package only.

  #in Ado::Control::List or Ado::Control::Foo or...
  my $myvalue = $c->config('mykey');
  #a shortcut to 
  my $myvalue = $app->config(__PACKAGE__)->{mykey}
  ...

To access the application-wide configuration use C<$c-E<gt>app-E<gt>config('key')>.

=head2 debug

A shortcut to:

  $c->app->log->debug(@_);

=head2 list_for_json

Prepares a structure suitable for rendering as JSON for 
listing  an ARRAYref of HASHES or L<Ado::Model>* objects,
returned by L<Ado::Model/select_range> and returns it.
Accepts two C<ARRAYREF>s as parameters:

  my $res = $c->list_for_json([$limit, $offset], \@list_of_AMobjects_or_hashes);

Use this method to ensure uniform and predictable representation
across all listing resources.
See L<http://127.0.0.1:3000/ado-users/list.json> for example output
and L<Ado::Control::Ado::Users/list> for the example source.

  my @range = ($c->param('limit') || 10, $c->param('offset') || 0);
  return $c->respond_to(
    json => $c->list_for_json(\@range, [Ado::Model::Users->select_range(@range)])
  );

  return $c->respond_to(
    json => $c->list_for_json(\@range, [$dbix->query($SQL,@range)->hashes])
  );

=head2 require_formats

Checks for a list of accepted formats or renders "415 - Unsupported Media Type"
with a text/html type and links to the preferred formats, and returns false.
If the URL is in the required format, returns true.
Adds a header C<Content-Location> pointing to the first URL of the required formats.

  #in an action serving only json
  sub list {
    my $c = shift;
    $c->require_formats('json') || return;
    $c->debug('rendering json only');
      #your stuff here...
      return;
  }

This method exists only to show more descriptive message with available formats
to the end user and to give a chance to user agents to go to the preferred resource URL.

=head2 validate_input

Uses L<Mojolicious::Controller/validation> to validate all input parameters at once
given a validation template.
The template consists of keys matching the input parameters to be validated.
The values are HASH references describing the rules. Each rule name corresponds 
to a method/check in L<Mojolicious::Validator/CHECKS>. You can use your own
checks if you add them using L<Mojolicious::Validator/add_check>.

Returns a HASH reference. 
In case of errors it contains C<errors> and C<json> HASH references.
In case of success contains only C<output> HASH reference from 
L<Mojolicious::Validator::Validation/output>.

    my $rules = {
        to_uid => {
            'required' => 1, like => qr/^\d{1,20}$/
        },
        subject => {
            'required' => 1, like => qr/^.{1,255}$/
        },
        #...
    }
    my $result = $c->validate_input($rules);

    #400 Bad Request
    return $c->render(
        status => 400,
        json   => $result->{json}
    ) if $result->{errors};

=head2 user

Returns the current user. This is the user C<guest> for not authenticated users.
Note that this instance is not meant for manipulation and some fields are not available
for security reasons. The fields are:
C<login_password created_by changed_by disabled start_date>.
TODO: move as much as possible checks and fields retrieval in SQL, not in Perl.


  $c->user(Ado::Model::Users->by_login_name($login_name));
  my $names = $c->user->name;


=head1 SEE ALSO

L<Mojolicious::Controller>, L<Ado::Manual::Controllers>,
L<Ado::Manual::RESTAPI>, L<DBIx::Simple>

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

