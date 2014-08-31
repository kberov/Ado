#apache2htaccess.t
use Mojo::Base -strict;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec::Functions qw(catdir catfile catpath);
use Mojo::Util qw(slurp);
use Test::Mojo;
my $IS_DOS = ($^O eq 'MSWin32' or $^O eq 'dos' or $^O eq 'os2');

#plan skip_all => 'Not reliable test under this platform.' if $IS_DOS;
my $t           = Test::Mojo->new('Ado');
my $app         = $t->app;
my $command     = 'Ado::Command::generate::apache2htaccess';
my $tempdir     = tempdir(CLEANUP => 1);
my $config_file = catfile($tempdir, '.htaccess');
use_ok($command);

ok( my $c = $app->start("generate", "apache2htaccess", '-M' => 'cgi,fcgid', '-c' => $config_file),
    'run() ok'
);
isa_ok($c, $command);
like($c->description, qr/Apache2\s+.htaccess/, 'description looks alike');
like($c->usage, qr/generate\sapache2htaccess.*?mod_fcgid/ms, 'usage looks alike');

ok(my $config_file_content = slurp($config_file), 'generated $config_file');
like($config_file_content, qr/<IfModule\s+mod_cgi.+?"\^\(ado\)\$"/msx, 'mod_cgi block produced');
like($config_file_content, qr/<IfModule\s+mod_fcgid\.c/msx, 'mod_fcgid block produced');

TODO: {
    local $TODO = 'Not reliable test under this platform.' if $IS_DOS;

# Note! not sure if the produced .htacces will work fine with Apache on Windows
# so make sure to test locally first.
    my ($perl, $app_home) = ($c->args->{perl}, $c->args->{DocumentRoot});

    my $plackup = $c->_which('plackup')
      if ( eval { require Plack }
        && eval { require FCGI }
        && eval { require FCGI::ProcManager }
        && eval { require Apache::LogFormat::Compiler });

    my $has_msfcgi = eval { require Mojo::Server::FastCGI };
    if ($has_msfcgi) {
        like(
            $config_file_content,
            qr|FcgidWrapper\s+".+/perl.+$app_home/bin/ado|,
            'path to FcgidWrapper is produced (Mojo::Server::FastCGI)'
        );
    }

    if ($plackup) {
        like(
            $config_file_content,
            qr|FcgidWrapper\s+"$plackup\s+$app_home/bin/ado\s+-s\s+FCGI\s+-l\s+|x,
            'path to FcgidWrapper is produced (Plack)'
        );
    }
    if (!$plackup && !$has_msfcgi) {
        like(
            $config_file_content,
            qr|no\sPlack\s.+neither\sMojo::Server::FastCGI|x,
            'no FcgidWrapper is produced because of missing modules'
        );
    }

}    # end TODO:

done_testing();
