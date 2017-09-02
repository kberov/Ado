#apache2vhost.t
use Mojo::Base -strict;
use File::Spec::Functions qw(catfile);
use File::Temp qw(tempdir);
use Mojo::File 'path';
use Test::Mojo;
use Test::More;

my $IS_DOS = ($^O eq 'MSWin32' or $^O eq 'dos' or $^O eq 'os2');

#plan skip_all => 'Not reliable test under this platform.' if $IS_DOS;


my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

my $command = 'Ado::Command::generate::apache2vhost';
my $tempdir = tempdir(CLEANUP => 1);

my $config_file = catfile($tempdir, 'example.com.conf');
use_ok($command);
ok( my $c = $app->start(
        "generate", "apache2vhost",
        '-n' => 'example.com',
        '-c' => $config_file,
        '-s'
    ),
    'run() ok'
);


isa_ok($c, $command);
like($c->description, qr/Apache2 Virtual Host/,            'description looks alike');
like($c->usage,       qr/the command-line.+with_suexec/ms, 'usage looks alike');
ok(my $config_file_content = path($config_file)->slurp(), 'generated $config_file');
my $app_home = $c->app->home;

like($config_file_content, qr/VirtualHost example.com:80/, 'produced file looks alike');
TODO: {
    local $TODO = 'Not reliable test under this platform.' if $IS_DOS;

    like($config_file_content, qr|ErrorLog\s+$app_home/log|,  'ErrorLog looks alike');
    like($config_file_content, qr|CustomLog\s+$app_home/log|, 'CustomLog looks alike');
    like($config_file_content, qr|Directory\s+"$app_home">|,  'Directory looks alike');
}    # end TODO:

done_testing;
