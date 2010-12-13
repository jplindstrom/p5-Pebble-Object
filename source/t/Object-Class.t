
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

sub get_object {
    my $meta_class = Pebble::Object::Class->new_meta_class([ "url", "size" ]);
    my $object = $meta_class->new_object( url => "http://localhost", size => 112211 );
    return $_ = $object;
}

sub mod_delete : Tests {
    my $self = shift;
    my $object = $self->get_object;

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

sub default_object : Tests {
    my $self = shift;
    my $object = $self->get_object;

    $_ = $object;
    my $new_object = Pebble::Object::Class->mod(
        -delete => "size",
    );
    is_deeply(
        $new_object->as_hashref,
        { url => "http://localhost" },
        "  and object looks ok",
    );
}


sub keep : Tests {
    my $self = shift;
    my $object = $self->get_object;

    is_deeply(
        Pebble::Object::Class->mod(
            -keep => [ ],
        )->as_hashref,
        { },
        "-keep none (empty hashref), nothing left",
    );
    
    is_deeply(
        Pebble::Object::Class->mod(
            -keep => "url",
        )->as_hashref,
        { url => "http://localhost" },
        "-keep one existing attribute, only that one left",
    );

    is_deeply(
        Pebble::Object::Class->mod(
            -keep => [ "url", "missing" ],
        )->as_hashref,
        { url => "http://localhost" },
        "-keep one extra (as hashref), didn't add anything",
    );
    
    
}


sub add : Tests {
    my $self = shift;
    my $object = $self->get_object;

    is_deeply(
        Pebble::Object::Class->mod(
            -add => { },
        )->as_hashref,
        { url => "http://localhost", size => 112211 },
        "-add none (empty hashref), same as before",
    );


    my $new_object = Pebble::Object::Class->mod(
        -object => $object,
        -add => { "time" => "1997-08-29" },
    );
    is_deeply(
        $new_object->as_hashref,
        { url => "http://localhost", , size => 112211, "time" => "1997-08-29" },
        "add an attribute/value, and it's added",
    );


    note "Same name as existing";
    $new_object = Pebble::Object::Class->mod(
        -object => $object,
        -add => { "url" => "file://abc.txt" },
    );
    is_deeply(
        $new_object->as_hashref,
        { url => "file://abc.txt", size => 112211 },
        "Existing field name overwrites its value",
    );
    
    
}

sub replace : Tests {
    my $self = shift;
    my $object = $self->get_object;

    is_deeply(
        Pebble::Object::Class->mod(
            -replace => { },
        )->as_hashref,
        { url => "http://localhost", size => 112211 },
        "-replace none (empty hashref), same as before",
    );


    my $new_object = Pebble::Object::Class->mod(
        -object => $object,
        -replace => {
            "url" => {
                time => "1997-08-29",
                html => "<html />",
            },
            size => {
            },
        },
    );
    is_deeply(
        $new_object->as_hashref,
        { "time" => "1997-08-29", html => "<html />" },
        "add an attribute/value, and it's added",
    );
}


note "Attributes";


note "All together";


