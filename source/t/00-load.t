#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Pebble::Object' ) || print "Bail out!
";
}

diag( "Testing Pebble::Object $Pebble::Object::VERSION, Perl $], $^X" );
