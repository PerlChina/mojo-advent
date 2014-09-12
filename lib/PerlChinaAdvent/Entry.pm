package PerlChinaAdvent::Entry;

use strict;
use warnings;
use base 'Exporter';
use vars qw/@EXPORT_OK/;
@EXPORT_OK = qw/get_day_file/;

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

1;