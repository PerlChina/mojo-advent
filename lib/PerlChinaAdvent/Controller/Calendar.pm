package PerlChinaAdvent::Controller::Calendar;

use Mojo::Base 'Mojolicious::Controller';
use PerlChinaAdvent::Entry qw/get_day_file render_pod/;

sub index {
    my $c = shift;

}

sub year {
    my $c = shift;

}

sub entry {
    my $c = shift;

    my $year = $c->stash('year');
    my $day  = $c->stash('day');

    my $file = get_day_file($year, $day);
    unless ($file) {
        return $c->render(
            template => 'not_found',
            status => 404
        );
    }

    my $html = render_pod($file);
    $c->stash('pod_html' => $html);
}

1;
