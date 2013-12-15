package Ado::Build;
use strict;
use warnings FATAL => 'all';
use File::Spec::Functions qw(catdir catfile);
use File::Path qw(make_path);
use File::Copy qw(copy);
use parent 'Module::Build';

sub process_public_files {
    my $self = shift;
    for my $asset (@{$self->rscan_dir('public')}) {
        if (-d $asset) {
            make_path(catdir('blib', $asset));
            next;
        }
        copy($asset, catfile('blib', $asset));
    }
    return;
}

sub process_etc_files {
    my $self = shift;
    for my $asset (@{$self->rscan_dir('etc')}) {
        if (-d $asset) {
            make_path(catdir('blib', $asset));
            next;
        }
        copy($asset, catfile('blib', $asset))
          unless $asset =~ /\d+\.sql/;
    }
    return;
}

sub process_log_files {
    my $self = shift;
    for my $asset (@{$self->rscan_dir('log')}) {
        if (-d $asset) {
            make_path(catdir('blib', $asset));
            next;
        }
        copy($asset, catfile('blib', $asset));
    }
    return;
}

sub ACTION_build {
    my $self = shift;

    #Make sure *log files are empty before moving them to blib
    _empty_log_files('log');

    #Do other interventions before the real build...
    $self->SUPER::ACTION_build;
    return;
}

sub ACTION_dist {
    my $self = shift;

    #Make sure *log files are empty before including them into the distro
    _empty_log_files('blib/log');

    #Do other interventions before the real dist..
    $self->SUPER::ACTION_dist;
    return;
}

sub ACTION_install {
    my $self = shift;

    #Custom functionality before installation
    #here...
    $self->SUPER::ACTION_install;

    #Custom functionality after installation
    my $etc_dir = $self->install_path('etc');
    my $log_dir = $self->install_path('log');

    #make some files writable and/or readable only by the user that runs the application
    #TODO: Think about what to do with *.conf and *.sqlite files in case of upgrade!!!
    for my $asset (qw(ado.conf plugins/routes.conf)) {
        chmod(0400, catfile($etc_dir, $asset))
          || Carp::carp("Problem with $etc_dir/$asset: $!");
    }
    chmod(0600, catfile($etc_dir, 'ado.sqlite'))
      || Carp::carp("Problem with $etc_dir/ado.sqlite: $!");

    #Make sure *log files are existing and empty
    _empty_log_files($self->install_path('log'));
    for my $asset (qw(development production)) {
        chmod(0600, catfile($log_dir, "$asset.log"))
          || Carp::carp("Problem with $log_dir/$asset.log: $!");
    }
    $self->_set_env();
    return;
}

#Sets Environmnent varable ADO_HOME in $HOME/.bashrc
sub _set_env {
    my $self = shift;
    return if ($ENV{ADO_HOME});    #ADO_HOME is set

    my $ado_home         = 'export ADO_HOME=' . $self->install_base;
    my $ADO_HOME_MESSAGE = <<"MESS";

Please do not forget to set ADO_HOME in your shell specific .*rc file:
$ado_home
so Ado plugins can easily find it.
MESS
    my $ADO_HOME_MESSAGE_SET_OK = <<"MESS";

Do you want me to write ADO_HOME to $ENV{HOME}/.bashrc 
so Ado plugins can easily find it?
MESS
    my $bashrc_file = catfile($ENV{HOME}, '.bashrc');
    if (!(-w $bashrc_file)) {
        $self->prompt($ADO_HOME_MESSAGE);
    }
    elsif (my $y = $self->prompt($ADO_HOME_MESSAGE_SET_OK, $ado_home)) {
        if (open my $bashrc, '>>', $bashrc_file) {
            say $bashrc "$/$ado_home$/";
            close $bashrc;
        }
        else {
            CORE::say STDERR 'ADO_HOME was not successfully set! Reason:' . $!
              . "$/Please do it manually.";
        }
    }
    return;
}

#Empties log files in a given directory.
sub _empty_log_files {
    (my ($log_dir) = @_) || Carp::croak('Please provide $log_dir');
    open my $logd, ">", "$log_dir/development.log" || Carp::croak $!;
    close $logd;
    open my $logp, ">", "$log_dir/production.log" || Carp::croak $!;
    close $logp;
    return;
}

sub do_create_readme {
    my $self = shift;
    if ($self->dist_version_from =~ /Ado\.pm$/) {

        #HACK to create README from Ado::Manual.pod
        require Pod::Text;
        my $readme_from = catfile('lib', 'Ado', 'Manual.pod');
        my $parser = Pod::Text->new(sentence => 0, indent => 2, width => 80);
        $parser->parse_from_file($readme_from, 'README');
    }
    else {
        $self->SUPER::do_create_readme();
    }
    return;
}
1;

__END__

=pod

=encoding utf8

=head1 NAME

Ado::Build - Custom routines for Ado installation 

=head1 SYNOPSIS

    #See Build.PL
    use Ado::Build;
    my $builder = Ado::Build->new(..);
    #...
    #$builder->create_build_script();

=head1 DESCRIPTION

This is where we place custom functionality, 
executed during the installation of L<Ado> by L<Module::Build>;


=head1 METHODS

=head2 process_etc_files

Moves files found in C<Ado/etc> to C<Ado/blib/etc>.
Returns void.

=head2 process_log_files

Moves files found in C<Ado/log> to C<Ado/blib/log>.
Returns void.

=head2 process_public_files

Moves files found in C<Ado/public> to C<Ado/blib/public>.
Returns void.

=head2 ACTION_build

You can put additional custom functionality here.

=head2 ACTION_dist

You can put additional custom functionality here.

=head2 do_create_readme

Creates the README file. It will be called during C<./Build dist> 
if you set the property C<create_readme> in C<Build.PL>.

=head2 ACTION_install

Changes file permissions to C<0600> of some files 
like C<etc/ado.sqlite> and to C<0400> of some files like C<etc/ado.conf>.
You can put additional custom functionality here.

=head1 SEE ALSO

L<Module::Build::API/CONSTRUCTORS>,

L<Module::Build::Cookbook/ADVANCED_RECIPES>,

L<Module::Build::API/METHODS>, Build.PL in Ado distribution directory.

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
