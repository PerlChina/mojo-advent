package PerlChinaAdvent;

use Mojo::Base 'Mojolicious';

sub startup {
    my $c = shift;

    $c->plugin('DefaultHelpers');
    $c->plugin('TagHelpers');

    my $r = $c->routes;

    $r->get('/')->to('calendar#index');
    $r->get('/calendar/')->to('calendar#index');

    my $r_year = $r->get('/calendar/:year' => [year => qr/\d+/]);

    $r_year->get('/')->to('calendar#year');
    $r_year->get('/:day' => [day => qr/\d+/])->to('calendar#entry');
}

1;
