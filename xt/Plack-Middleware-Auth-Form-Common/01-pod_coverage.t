use strict;
use warnings;

use Test::NoWarnings;
use Test::Pod::Coverage 'tests' => 2;

# Test.
pod_coverage_ok('Plack::Middleware::Auth::Form::Common', 'Plack::Middleware::Auth::Form::Common is covered.');
