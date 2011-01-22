#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use open ":utf8";
use open ":std";
use feature qw( say switch );
use lib "lib";
use App::MakeFileOrder;

my @order_list = grep { $_ !~ m{\A \s* [#] }msx }
                 grep { $_ }
                 map  { chomp; $_ }
                 <DATA>;
#say join "\n", @order_list; exit;

App::MakeFileOrder->new(
    mode    => "git",
    dir     => "sample",
    order   => \@order_list,
    verbose => 1,
    dry_run => 0,
)->rename;

__DATA__
prereq.t
use.t
can.t
new.t

