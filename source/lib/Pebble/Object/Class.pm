
=head1 NAME

Pebble::Object::Class - Class for Pebble objects

=cut

package Pebble::Object::Class;
use Moose;
use MooseX::Method::Signatures;

use Carp;
use Data::Dumper;
use JSON::XS;

#TODO: cache the metaclass creation on join("-", sort @$has)
method new_meta_class($class: $has) {
    #TODO: move this into application code, it should be possible to
    #create an empty class
    @$has or die( "Can't define class: No field names provided (with 'has')\n" );

    my $meta_class = Moose::Meta::Class->create_anon_class(
        superclasses => [ "Pebble::Object" ],
    );
    for my $field (@$has) {
        $meta_class->add_attribute( $field => ( is => 'rw' ) );
    }    

    return $meta_class;
}

sub mod {
    my $class = shift;
    my %arg = @_;

    my $object = $arg{-object};
    if( ! ( blessed( $object ) && $object->isa( "Pebble::Object" ) ) ) {
        my $o = $object || "";
        croak( "($o) is not a Pebble::Object" );
    }  
    
    my $meta_class = $object->meta;

    my $to_delete = $class->as_hashref( $arg{-delete} );
    my $new_attributes = [
        grep { ! $to_delete->{$_} }
        map { $_->name }
#        map { warn Data::Dumper->new( [ $_ ] )->Maxdepth(1)->Dump(); $_ }
        $meta_class->get_all_attributes
    ];

    my $new_meta_class = $class->new_meta_class( $new_attributes );
    
    my $new_object = $new_meta_class->new_object( %$object );
    
    return $new_object;
}

method as_hashref($class: $scalar_or_arrayref) {
    my $arrayref = $class->as_arrayref( $scalar_or_arrayref );
    return { map { $_ => 1 } @$arrayref };
}

method as_arrayref($class: $scalar_or_arrayref) {
    defined $scalar_or_arrayref or return [];
    ref( $scalar_or_arrayref ) eq "ARRAY" and return $scalar_or_arrayref;
    return [ $scalar_or_arrayref ];
}

1;
