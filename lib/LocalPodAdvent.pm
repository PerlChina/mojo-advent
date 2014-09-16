package LocalPodAdvent;

use Encode;
use parent Pod::Advent;

sub new {
    my $self = shift->SUPER::new(@_);
    $Pod::Advent::BODY_ONLY = 1;
    return $self;
}

sub parse_file {
    my $self = shift;
    my $filename = shift;
    my %result;

    open my $fh, $filename or die "Can't open $filename: $!\n";
    while (my $line = <$fh>) {
        chomp $line;
        next if $line =~ /^\s*$/;
        last if $line =~ /^[^=\s]/;

        if ( $line =~ /^=(encoding|for\s+\w+)\s+(.+)/ ) {
            my ($key, $val) = ($1, $2);
            $key =~ s/^for\s+//;
            $result{$key} = $val;
        } 
    }
    close $fh;

    map { $result{$_} = decode($result{encoding} ? $result{encoding} : "utf8", $result{$_}) } keys %result;

    $self->output_string( \$result{body} );
    $self->SUPER::parse_file($filename, @_);
    return \%result;
}

1;
