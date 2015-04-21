#t/ado/lib/Ado/Plugin/Bar.pm
package Ado::Plugin::Bar;
use Mojo::Base 'Ado::Plugin';

#For testing syntax error in config files
has ext => 'dummy';
has config_classes => sub { {dummy => 'Mojolicious::Plugin::Config'} };

sub register {
    my ($self, $app, $config) = shift->initialise(@_);

    # Do plugin specific stuff
    # here...
    # ...
    return $self;
}
1;
