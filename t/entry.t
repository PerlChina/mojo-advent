#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use PerlChinaAdvent::Entry qw/get_day_file/;

my $file = get_day_file(2009, 1);
ok($file =~ /local_lib\.pod/);

done_testing();

1;