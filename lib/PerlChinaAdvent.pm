package PerlChinaAdvent;

use Mojo::Base 'Mojolicious';

sub startup {
  my $c = shift;

  my $r = $c->routes;

  $r->get('/')->to('calendar#index');
}

1;
