package Ado::Build;
use 5.014;
use strict;
use warnings FATAL => 'all';
use File::Spec::Functions qw(catdir catfile catpath);
use File::Path qw(make_path);
use File::Copy qw(copy);
use Cwd qw(abs_path);
use ExtUtils::Installed;
use ExtUtils::Install;
use parent 'Module::Build';
use Exporter qw( import );    #export functionality to Ado::BuildPlugin etc..
our @EXPORT_OK = qw(
  create_build_script process_etc_files
  process_public_files process_templates_files
  ACTION_perltidy ACTION_submit);

#Shamelessly stollen from File::HomeDir::Windows
my $HOME =
     $ENV{HOME}
  || $ENV{USERPROFILE}
  || (
    $ENV{HOMEDRIVE} && $ENV{HOMEPATH}
    ? catpath($ENV{HOMEDRIVE}, $ENV{HOMEPATH}, '')
    : abs_path('./')
  );


sub create_build_script {
    my $self = shift;

    #Deciding where to install
    my $c = $self->{config};
    my $prefix = $self->install_base || $c->get('siteprefixexp');
    for my $be (qw(etc public log templates)) {

        #in case of installing a plugin, check if folder exists
        next unless -d $be;
        $self->add_build_element($be);
        $self->install_path($be => catdir($prefix, $be));
    }
    return $self->SUPER::create_build_script();
}

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

sub process_templates_files {
    my $self = shift;
    for my $asset (@{$self->rscan_dir('templates')}) {
        if (-d $asset) {
            make_path(catdir('blib', $asset));
            next;
        }
        copy($asset, catfile('blib', $asset));
    }
    return;
}

sub _get_packlist {
    my $self = shift;

    my $module    = $self->module_name;
    my $installed = ExtUtils::Installed->new;

    return $installed->packlist($module)->packlist_file;
}

sub ACTION_uninstall {
    my $self = shift;
    return ExtUtils::Install::uninstall($self->_get_packlist, 1);
}

sub ACTION_fakeuninstall {
    my $self = shift;
    return ExtUtils::Install::uninstall($self->_get_packlist, 1, 1);
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
    $self->depends_on("perltidy");

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
    #TODO: Think about what to do with *.conf and *.sqlite files in case of upgrade!!!
    #TODO: (upgrade)rotate logs - archive existing log files before emptying.
    $self->SUPER::ACTION_install;

    #Custom functionality after installation
    #see below
    my $etc_dir = $self->install_path('etc');
    my $log_dir = $self->install_path('log');

    #make some files writable and/or readable only by the user that runs the application
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

    return;
}

sub ACTION_perltidy {
    my $self = shift;
    require File::Find;
    eval { require Perl::Tidy } || do {
        say "Perl::Tidy is not installed$/" . "Please install it and rerun ./Build perltidy";
        return;
    };
    my @files;
    File::Find::find(
        {   no_chdir => 1,
            wanted   => sub {
                return if -d $File::Find::name;
                my $file = $File::Find::name;
                unlink $file and return if $file =~ /.bak/;
                push @files, $file
                  if $file =~ m/(\.conf|\.pm|.pl|ado\|\.t)$/x;
            },
        },
        map { abs_path($_) } (qw(bin lib etc t))
    );

    #We use ./.perltidyrc for all arguments
    Perl::Tidy::perltidy(argv => [@files, 'Build.PL']);
    foreach my $file (@files) {
        unlink("$file.bak") if -f "$file.bak";
    }
    return 1;
}

sub ACTION_submit {
    my $self = shift;
    $self->depends_on("perltidy");
    say "TODO: commit and push after tidying and testing and who knows what";
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

        #Create README from Ado::Manual.pod
        require Pod::Text;
        my $readme_from = catfile('lib', 'Ado', 'Manual.pod');
        my $parser = Pod::Text->new(sentence => 0, indent => 2, width => 76);
        $parser->parse_from_file($readme_from, 'README');
        $self->log_info('Created README' . $/);

        #add README.md just to be cool..
        eval { require Pod::Markdown }
          || return $self->log_warn('Pod::Markdown required for creating README.md' . $/);
        require Mojo::Util;
        $parser = Pod::Markdown->new;
        my $manual = 'lib/Ado/Manual.pod';
        if (my $readme_fh = IO::File->new($manual)) {
            $parser->parse_from_filehandle($readme_fh);
            Mojo::Util::spurt($parser->as_markdown, 'README.md');
            $self->log_info('Created README.md' . $/);
        }
        else {
            $self->log_warn("Could not open $manual:$!$/");
        }
    }
    else {
        $self->SUPER::do_create_readme();
    }
    return;
}

1;

=pod

=encoding utf8

=head1 NAME

Ado::Build - Custom routines for Ado installation 

=head1 SYNOPSIS

  #See Build.PL
  use 5.014000;
  use strict;
  use warnings FATAL => 'all';
  use FindBin;
  use lib("$FindBin::Bin/lib");
  use Ado::Build;
  my $builder = Ado::Build->new(..);
  $self->create_build_script();
  
  #on the command line
  cd /path/to/cloned/Ado
  perl Build.PL
  ./Build
  ./Build test
  #change/add some code
  ./Build test
  ./Build perltidy
  ./Build dist
  ./Build submit
  #.... and so on


=head1 DESCRIPTION

This is a subclass of L<Module::Build>. We use L<Module::Build::API> to add
custom functionality so we can install Ado in a location chosen by the user.


This module and L<Ado::BuildPlugin> exist just because of the additional install paths
that we use beside C<lib> and C<bin>. These modules also can serve as examples 
for your own builders if you have some custom things to do during 
build, test, install and even if you need to add a new C<ACTION_*> to your setup.

=head1 METHODS

Ado::Build inherits all methods from L<Module::Build> and implements 
the following ones.

=head2 create_build_script

This method is called in C<Build.PL>.
In this method we also call C<add_build_element> for C<etc> C<public>,
C<templates> and C<log> folders. 
Finally we set all the C<install_path>s for the distro
and we call C<$self-E<gt>SUPER::create_build_script>.

=head2 process_etc_files

Moves files found in C<Ado/etc> to C<Ado/blib/etc>.
See L<Module::Build::API/METHODS>
Returns void.

=head2 process_log_files

Moves files found in C<Ado/log> to C<Ado/blib/log>.
Returns void.

=head2 process_public_files

Moves files found in C<Ado/public> to C<Ado/blib/public>.
Returns void.

=head2 process_templates_files

Moves files found in C<Ado/templates> to C<Ado/blib/templates>.
Returns void.

=head2 ACTION_build

We put here custom functionality executed around the
C<$self-E<gt>SUPER::ACTION_build>. See the source for details.

=head2 ACTION_dist

We put here custom functionality executed around the
C<$self-E<gt>SUPER::ACTION_dist>. See the sources for details.

=head2 ACTION_install

Changes file permissions to C<0600> of some files 
like C<etc/ado.sqlite> and to C<0400> of some files like C<etc/ado.conf>.
You can put additional custom functionality here.

=head2 ACTION_fakeuninstall

Dry run for uninstall operation against module Ado.

=head2 ACTION_uninstall

Perform uninstall operation against Ado module.

=head2 ACTION_perltidy

This is a custom action. Tidies all C<*.conf, *.pm, *.pl,*.t> 
files found in directories C<./lib, ./t ./etc>
in the distribution. uses the C<./pertidyrc> found in the root 
directory of the distribution.
This action is run first always when you run C<./Build dist>.

  ./Build perltidy

=head2 ACTION_submit

TODO: commit and push after testing tidying and who knows what..

  ./Build submit



=head2 do_create_readme

Creates the README file from C<lib/Ado/Manual.pod>. 

=head1 SEE ALSO

L<Ado::BuildPlugin>,
L<Module::Build::API>,
L<Module::Build::Authoring>,
L<Module::Build::Cookbook/ADVANCED_RECIPES>,
Build.PL in Ado distribution directory.

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

