
=head1 NAME

Pebble::Object::Class - Class for Pebble objects

=cut

package Pebble::Object::Class;
use strict;
use warnings;

use Method::Signatures;
use Scalar::Util qw/ blessed /;

use Carp qw/ confess /;
use Data::Dumper;
use JSON::XS;
use Storable qw/ dclone /;

use Pebble::Object;


sub new {
    my $class = shift;
    my $object = Pebble::Object->new();
    return $class->modify(
        -object => $object,
        @_,
    );
}

sub clone {
    my $class = shift;
    my ($object) = @_;
    
    my $mop1 = $object->{__MOP__};
    my $mop2 = $object->{"<<MOP>>"};
    
    local $object->{__MOP__};
    local $object->{"<<MOP>>"};
    my $clone = dclone( $object );
    $mop1 and $clone->{__MOP__} = $mop1;
    $mop2 and $clone->{"<<MOP>>"} = $mop2;

    return $clone;
}

my $_key_meta_class = {};
method new_meta_class($class: $has) {
    my $key = join( "-", sort @$has );

    return $_key_meta_class->{ $key } ||= do {
        my $meta_class = Moose::Meta::Class->create_anon_class(
            superclasses => [ "Pebble::Object" ],
        );
        for my $field (@$has) {
            $meta_class->add_attribute( $field => ( is => 'rw' ) );
        }

        $meta_class->make_immutable;
        $meta_class;
    };
}

sub modify {
    my $class = shift;
    my %arg = @_;

    my $object = exists $arg{-object} ? $arg{-object} : $_;
    if( ! ( blessed( $object ) && $object->isa( "Pebble::Object" ) ) ) {
        my $o = $object || "";
        confess( "($o) is not a Pebble::Object" );
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
