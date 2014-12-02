package PerlChinaAdvent::Entry;

use strict;
use warnings;
use v5.10;
use base 'Exporter';
use vars qw/@EXPORT_OK/;
@EXPORT_OK = qw/get_day_file get_available_years get_available_days render_pod render_markdown get_current_year/;

use LocalPodAdvent;
use Text::Markdown 'markdown';
use Mojo::Util qw/slurp/;
use Encode;

use File::Spec;
use Cwd qw/abs_path/;
my ( undef, $path ) = File::Spec->splitpath(__FILE__);
my $root_path = abs_path( File::Spec->catdir( $path, '..', '..' ) );

sub get_day_file {
    my ($year, $day) = @_;

    $day = sprintf('%02d', $day);
    opendir(my $dir, "$root_path/articles/$year/$day") or return;
    my @files = grep { /\.(pod|md)/i } readdir($dir);
    closedir($dir);
    warn " #[FIX] More than one file in $root_path/articles/$year/$day.\n" if @files > 1;
    return "$root_path/articles/$year/$day/" . $files[0];
}

sub get_available_years {
    opendir(my $dir, "$root_path/articles");
    my @years = grep { /^20\d{2}$/ } readdir($dir);
    closedir($dir);
    return sort @years;
}

sub get_available_days {
    my ($year) = @_;

    opendir(my $dir, "$root_path/articles/$year") or return;
    my @days = grep { /^\d{1,2}$/ } readdir($dir);
    closedir($dir);
    return @days;
}

sub render_pod {
    my ($file) = @_;
    my $advent = LocalPodAdvent->new;
    my $result = $advent->parse_file($file);
    return $result;
}

sub render_markdown {
    my ($file) = @_;
    my $content = slurp($file);
    my $title = (split(/[\r\n]+/, $content))[0]; # default first line as title
    $title =~ s/^\#\s*//;
    return {
        advent_title => $title,
        body  => markdown(decode_utf8($content))
    };
}

## Date related
sub get_current_year {
    return (localtime())[5] + 1900;
}

1;
