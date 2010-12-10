
=head1 NAME

Pebble::Object::Class - Class for Pebble objects

=cut

package Pebble::Object::Class;
use Moose;
use MooseX::Method::Signatures;

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

1;
