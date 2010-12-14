
=head1 NAME

Pebble::Object::Class - Class for Pebble objects

=cut

package Pebble::Object::Class;
use MooseX::Method::Signatures;
use Scalar::Util qw/ blessed /;

use Carp qw/ confess /;
use Data::Dumper;
use JSON::XS;

use Pebble::Object;


sub new {
    my $class = shift;
    my $object = Pebble::Object->new();
    return $class->modify(
        -object => $object,
        @_,
    );
}

#TODO: cache the metaclass creation on join("-", sort @$has)
method new_meta_class($class: $has) {
    #TODO: move this into application code, it should be possible to
    #create an empty class
#    @$has or die( "Can't define class: No field names provided (with 'has')\n" );

    my $meta_class = Moose::Meta::Class->create_anon_class(
        superclasses => [ "Pebble::Object" ],
    );
    for my $field (@$has) {
        $meta_class->add_attribute( $field => ( is => 'rw' ) );
    }

    return $meta_class;
}

sub modify {
    my $class = shift;
    my %arg = @_;

    my $object = exists $arg{-object} ? $arg{-object} : $_;
    if( ! ( blessed( $object ) && $object->isa( "Pebble::Object" ) ) ) {
        my $o = $object || "";
        confess( "($O) is not a Pebble::Object" );
    }

    my $meta_class = $object->meta;
    my $new_attribute_value = $object->as_hashref;
    my @existing_attributes = map { $_->name } $meta_class->get_all_attributes;


    my $to_keep = $arg{-keep}
        ? $class->as_hashref( $arg{-keep} )
        : { map { $_ => 1 } @existing_attributes };
#warn( "to_keep: " . Data::Dumper->new( [ $to_keep ] )->Maxdepth(1)->Dump() );

    my $to_delete = $class->as_hashref( $arg{-delete} );
    my $to_replace = $arg{-replace} || { }; ###TODO: validate it's a hashref

    my $new_attributes = [
        grep { ! $to_delete->{$_} }
        grep { ! $to_replace->{$_} }
        grep { $to_keep->{$_} }
#        map { warn Data::Dumper->new( [ $_ ] )->Maxdepth(1)->Dump(); $_ }
        @existing_attributes,
    ];
    
    my $to_add = $arg{-add} || {}; #TODO: validate it's a hashref
    for my $to_replace_with ( values %$to_replace ) {
        for my $attribute ( keys %$to_replace_with ) {
            $to_add->{ $attribute } = $to_replace_with->{ $attribute };
        }
    }
    for my $attribute ( grep { ! /^-/ } keys %arg ) {
        $to_add->{ $attribute } = $arg{ $attribute };
    }
    
    for my $attribute ( keys %$to_add ) {
        push( @$new_attributes, $attribute );
        $new_attribute_value->{ $attribute } = $to_add->{ $attribute };
    }

    my $new_meta_class = $class->new_meta_class( $new_attributes );
    my $new_object = $new_meta_class->new_object( %$new_attribute_value );

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
