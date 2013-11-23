package Ado::Build;
use strict;
use warnings FATAL => 'all';
use File::Spec::Functions qw(catdir catfile);
use base 'Module::Build';

sub process_public_files {
    my $self = shift;
    for my $asset (@{$self->rscan_dir('public')}) {
        if (-d $asset) {
            File::Path::make_path(catdir('blib', $asset));
            next;
        }
        File::Copy::copy($asset, catfile('blib', $asset));
    }
    return;
}

sub process_etc_files {
    my $self = shift;

    #configuration files should be 'rw' by the owner only

    for my $asset (@{$self->rscan_dir('etc')}) {
        if (-d $asset) {
            File::Path::make_path(catdir('blib', $asset));
            next;
        }
        File::Copy::copy($asset, catfile('blib', $asset));
        chmod 0600, catfile('blib', $asset);
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

=head2 process_public_files

Moves files found in C<Ado/public> to C<Ado/blib/public>.
Returns void.

=head1 SEE ALSO

L<Module::Build::API/CONSTRUCTORS>,
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
