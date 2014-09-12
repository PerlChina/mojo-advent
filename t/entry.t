#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use PerlChinaAdvent::Entry qw/get_day_file render_pod/;

my $file = get_day_file(2009, 1);
ok($file =~ /local_lib\.pod/);

my $html = render_pod($file);
ok($html =~ m{perl Makefile.PL --bootstrap});

done_testing();

1;