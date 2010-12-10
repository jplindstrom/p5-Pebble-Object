
use strict;
use warnings;
use Test::More "no_plan";
use Test::Exception;

use Pebble::Object::Class;


note "No attributes";
throws_ok(
    sub { Pebble::Object::Class->new_meta_class([]) },
    qr/Can't define class: No field names provided \(with 'has'\)/,
    "No attributes dies ok",
);


note "An attribute";
{
    ok(
        my $meta_class = Pebble::Object::Class->new_meta_class([ "name" ]),
        "Can create meta_class"
    );
    ok(
        my $object = $meta_class->new_object( name => "Johan" ),
        "Can instantiate meta class"
    );
    isa_ok( $object, "Pebble::Object" );
    is_deeply( $object->as_hashref, { name => "Johan" }, "  and object looks ok" );
}




note "mod -delete";
{
    my $meta_class = Pebble::Object::Class->new_meta_class([ "url", "size" ]);
    my $object = $meta_class->new_object( url => "http://localhost", size => 112211 );


    my $new_object = Pebble::Object::Class->mod(
        -object => $object,
        -delete => "size",
    );
    is_deeply(
        $new_object->as_hashref,
        { url => "http://localhost" },
        "  and object looks ok",
    );
    is_deeply(
        $object->as_hashref,
        { url => "http://localhost", size => 112211 },
        "  and original object is the same",
    );
    
}


note "Bad object";


note "Default object";


note "keep";


note "add";


note "replace";


note "Attributes";


note "All together";


