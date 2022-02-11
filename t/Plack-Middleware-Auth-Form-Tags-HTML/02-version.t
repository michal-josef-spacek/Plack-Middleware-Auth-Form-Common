use strict;
use warnings;

use Plack::Middleware::Auth::Form::Tags::HTML;
use Test::More 'tests' => 2;
use Test::NoWarnings;

# Test.
is($Plack::Middleware::Auth::Form::Tags::HTML::VERSION, 0.01, 'Version.');
