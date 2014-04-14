package Ado::Model::Wiki;

use 5.010001;
use strict;
use warnings;
use utf8;
use parent qw(Ado::Model);

sub init {
    warn "TODO: Initializing wiki table in database.";
}

sub is_base_class {
    return 0;
}

my $TABLE_NAME = 'user_group';

1;
