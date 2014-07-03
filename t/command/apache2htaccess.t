#apache2htaccess.t
use Mojo::Base -strict;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec::Functions qw(catdir catfile catpath);
use Mojo::Util qw(slurp);

my $command = 'Ado::Command::generate::apache2htaccess';
use_ok($command);
isa_ok(my $c = $command->new, $command);
like($c->description, qr/Apache2\s+.htaccess/, 'description looks alike');
like($c->usage, qr/generate\sapache2htaccess.*?mod_fcgid/ms, 'usage looks alike');
my $config_file = catfile(tempdir, '.htaccess');
ok(!$c->run('-m' => 'cgi,fcgid', '-c' => $config_file), 'run() ok');
ok(my $config_file_content = slurp($config_file), 'generated $config_file');
like($config_file_content, qr/<IfModule mod_cgi.+?"\^\(ado\)\$"/ms,   'mod_cgi block produced');
like($config_file_content, qr/<IfModule mod_fcgid.+?"\^\(ado\)\$"/ms, 'mod_fcgid block produced');

# Note! not sure if the produced .htacces will work fine with Apache on Windows
# so make sure to test locally first.
my ($perl, $app_home) = ($c->args->{perl}, $c->args->{DocumentRoot});
if ($^O eq 'MSWin32') {
    ok($app_home !~ m/\\/, 'DocumentRoot - only forward slashes');
    ok($perl !~ m/\\/,     'perl path - only forward slashes');
}
my $plackup = $c->_which('plackup');
if (!$plackup && eval {require Mojo::Server::FastCGI}) {
    like(
        $config_file_content,
        qr|FcgidWrapper\s+"\Q$perl $app_home\E/bin/ado|,
        'path to FcgidWrapper is produced (Mojo::Server::FastCGI)'
    );
}

if($plackup){
  like(
        $config_file_content,
        qr|FcgidWrapper\s+"\Q$plackup $app_home\E/bin/ado -s FCGI -l |,
        'path to FcgidWrapper is produced (Plack)'
    );
}

done_testing();
