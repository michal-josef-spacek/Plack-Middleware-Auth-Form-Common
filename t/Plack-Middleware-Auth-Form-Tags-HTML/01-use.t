use strict;
use warnings;

use Test::More 'tests' => 3;
use Test::NoWarnings;

BEGIN {

	# Test.
	use_ok('Plack::Middleware::Auth::Form::Tags::HTML');
}

# Test.
require_ok('Plack::Middleware::Auth::Form::Tags::HTML');
