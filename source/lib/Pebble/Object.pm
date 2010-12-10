
=head1 NAME

Pebble::Object - Base class for Pebble objects

=cut

package Pebble::Object;
use Moose;
use MooseX::Method::Signatures;

use JSON::XS;

method as_json {
    my $encoder = JSON::XS->new; #->pretty;
    my $json = $encoder->encode( $self->as_hashref );
    chomp( $json );

    return "$json\n";
}

method as_hashref {
    my %attr = %$self;
    delete $attr{__MOP__};
    delete $attr{"<<MOP>>"};
    return \%attr;
}

# maybe, not sure about this one at all
method fields(@fields) {
    join( ", ", map { $self->$_ } @fields );
}
 
use overload q|""| => \&as_json, fallback => 1;

1;
