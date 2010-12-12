
use Test::Class::Most;
Test::Class->runtests;

use Pebble::Object::Class;

sub no_attributes : Tests {
    throws_ok(
        sub { Pebble::Object::Class->new_meta_class([]) },
        qr/Can't define class: No field names provided \(with 'has'\)/,
        "No attributes dies ok",
    );
}

sub an_attribute : Tests {
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

sub mod_delete : Tests {
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


sub bad_object : Tests {

    throws_ok(
        sub {
            Pebble::Object::Class->mod(
                -object => undef,
                -delete => "size",
            );
        },
        qr/\(\) is not a Pebble::Object/,
        "Failed undef, not a Pebble::Object",
    );

    throws_ok(
        sub {
            Pebble::Object::Class->mod(
                -object => "abc",
                -delete => "size",
            );
        },
        qr/\(abc\) is not a Pebble::Object/,
        "Failed string, not a Pebble::Object",
    );

    throws_ok(
        sub {
            Pebble::Object::Class->mod(
                -object => Pebble::Object::Class->new,
                -delete => "size",
            );
        },
        qr/\(Pebble::Object::Class=HASH\(\w+\)\) is not a Pebble::Object/,
        "Failed other class, not a Pebble::Object",
    );
    
}

note "Default object";


note "keep";


note "add";


note "replace";


note "Attributes";


note "All together";


