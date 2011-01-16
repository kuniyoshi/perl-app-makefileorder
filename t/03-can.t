use strict;
use warnings;
use Test::More tests => 1;

my $module  = "App::MakeFileOrder";
my @methods = qw( new  move  rename );

eval "use $module";

can_ok( $module, @methods );

