use inc::Module::Install;

name     'Pebble-Object';
all_from 'lib/Pebble/Object.pm';
author   q{Johan Lindstrom <johanl@cpan.org>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

