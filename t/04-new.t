use strict;
use warnings;
use Test::More tests => 1;

my $module = "App::MakeFileOrder";

eval "use $module";

new_ok( $module, [ mode => "git", index => [ qw( use can new ) ] ] );

