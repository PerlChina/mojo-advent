#!/usr/bin/perl

use strict;
use warnings;
use Test::More;
use PerlChinaAdvent::Entry qw/get_day_file get_available_years get_available_days get_current_year render_pod/;

my $file = get_day_file(2009, 1);
ok($file =~ /local_lib\.pod/);

my @years = get_available_years();
ok(grep { $_ == 2009 } @years);

my @days = get_available_days(2009);
ok(grep { $_ == 1 } @days);
ok(grep { $_ == 2 } @days);
ok(grep { $_ == 24 } @days);

my $year = get_current_year();
ok($year > 2013);
ok($year < 3000);

my $html = render_pod($file);
ok($html =~ m{perl Makefile.PL --bootstrap});

done_testing();

1;