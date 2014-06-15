#apache2htaccess.t
use Mojo::Base -strict;
use Test::More;
use File::Temp qw(tempdir);
use File::Spec::Functions qw(catdir catfile catpath);

use Mojo::Util qw(slurp);

done_testing();
