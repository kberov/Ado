package Ado::Command::version;
use Mojo::Base 'Ado::Command';
use Mojolicious::Command::version;


has description => "Show versions of installed modules.\n";
has usage       => "usage: $0 version\n";

has latest => sub {
    my $latest = eval {
        my $ua = Mojo::UserAgent->new(max_redirects => 10);
        $ua->proxy->detect;
        $ua->get('api.metacpan.org/v0/release/Ado')->res->json->{version};
    };
    return $latest;
};

#We do not get arguments from @ARGV now
sub init {
    my $self = shift;
    $self->args->{do} = 'version';

    return 1;
}

#the only action this command implements
sub version {
    my $self = shift;

    my $msg = "$/ADO:$/  "
      . Mojo::Util::encode(Mojo::Message->new->default_charset,
        $Ado::VERSION . ' - ' . $Ado::CODENAME);
    my $latest = $self->latest;
    if ($latest) {
        $msg .= "$/  This version is up to date, have fun!$/"
          if $latest == $Ado::VERSION;
        $msg .= "$/  Thanks for testing a development release, you are awesome!$/"
          if $latest < $Ado::VERSION;
        $msg .= "$/  You might want to update your Ado to $latest.$/"
          if $latest > $Ado::VERSION;
    }
    say $msg;
    Mojolicious::Command::version->new->run();
    return;
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Command::version - Version command

=head1 SYNOPSIS

  use Ado::Command::version;

  my $v = Ado::Command::version->new;
  $v->run();

=head1 DESCRIPTION

L<Ado::Command::version> shows version information for installed core
and optional modules.

This is a core command, that means it is always enabled and its code a good
example for learning to build new commands, you're welcome to fork it.

=head1 ATTRIBUTES

L<Ado::Command::version> inherits all attributes from
L<Ado::Command> and implements the following new ones.

=head2 description

  my $description = $v->description;
  $v              = $v->description('Foo!');

Short description of this command, used for the command list.

=head2 usage

  my $usage = $v->usage;
  $v        = $v->usage('Foo!');

Usage information for this command, used for the help screen.

=head2 latest

Checks for the latest version on metacpan.org and returns it 
if successfully connected

=head1 METHODS

L<Ado::Command::version> inherits all methods from
L<Ado::Command> and implements the following new ones.

=head2 init

Default initialization.

=head2 version

  #set in init().
  $self->args->{do} ='version';
  
The default and only action this command implements.
See L<Ado::Command/run>.


=head1 SEE ALSO

L<Mojolicious::Command::version>, L<Ado::Command> L<Ado::Manual>,
L<Mojolicious>, L<Mojolicious::Guides>.

=cut

