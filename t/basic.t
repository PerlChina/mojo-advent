use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('PerlChinaAdvent');
$t->get_ok('/')->status_is(200)->content_like(qr/PerlChina Advent/i);

done_testing();
