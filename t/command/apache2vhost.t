#apache2vhost.t
use Mojo::Base -strict;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec::Functions qw(catfile);
use Mojo::Util qw(slurp);
use Test::Mojo;
my $IS_DOS = ($^O eq 'MSWin32' or $^O eq 'dos' or $^O eq 'os2');

plan skip_all => 'Not reliable test under this platform.' if $IS_DOS;


my $t   = Test::Mojo->new('Ado');
my $app = $t->app;

my $command = 'Ado::Command::generate::apache2vhost';
my $config_file = catfile(tempdir, 'example.com.conf');
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
ok(my $config_file_content = slurp($config_file), 'generated $config_file');
my $app_home = $c->app->home;

like($config_file_content, qr/VirtualHost example.com:80/,    'produced file looks alike');
like($config_file_content, qr|ErrorLog\s+\Q$app_home\E/log|,  'ErrorLog looks alike');
like($config_file_content, qr|CustomLog\s+\Q$app_home\E/log|, 'CustomLog looks alike');
like($config_file_content, qr|Directory\s+"\Q$app_home\E">|,  'Directory looks alike');

done_testing;
