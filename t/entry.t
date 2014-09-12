#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use PerlChinaAdvent::Entry qw/get_day_file get_available_years render_pod/;

my $file = get_day_file(2009, 1);
ok($file =~ /local_lib\.pod/);

my @years = get_available_years();
diag(Dumper(\@years)); use Data::Dumper;
ok(grep { $_ == 2009 } @years);

my $html = render_pod($file);
ok($html =~ m{perl Makefile.PL --bootstrap});

done_testing();

1;