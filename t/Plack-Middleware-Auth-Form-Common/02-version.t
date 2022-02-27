use strict;
use warnings;

use Plack::Middleware::Auth::Form::Common;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::Middleware::Auth::Form::Common::VERSION, 0.01, 'Version.');
