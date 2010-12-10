
use strict;
use warnings;
use Test::More "no_plan";
use Test::Exception;

use Pebble::Object;


note "No attributes";
throws_ok(
    sub { Pebble::Object->new_meta_class([]) },
    qr/Can't define class: No field names provided \(with 'has'\)/,
    "No attributes dies ok",
);



ok( my $meta_class = Pebble::Object->new_meta_class([ "name" ]), "Can create meta_class" );
ok( my $object = $meta_class->new_object( name => "Johan" ), "Can instantiate meta class" );




