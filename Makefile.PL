use lib '.';
use strict;
use warnings;

use inc::Module::Install;

# Definition.
abstract 'Plack middleware for auth form with Tags::HTML.';
author 'Michal Josef Spacek <skim@cpan.org>';
author_requires 'English' => 0;
author_requires 'File::Object' => 0;
author_requires 'Test::More' => 0;
author_requires 'Test::NoWarnings' => 0;
author_requires 'Test::Pod' => 0;
author_requires 'Test::Pod::Coverage' => 0;
license 'bsd';
name 'Plack-Middleware-Auth-Form-Tags-HTML';
perl_version 5.008;
readme_from 'HTML.pm';
recursive_author_tests('xt');
requires 'Error::Pure' => 0;
requires 'JSON::XS' => 0;
requires 'LWP::Authen::OAuth2' => 0;
requires 'Plack::Response' => 0;
requires 'Plack::Session' => 0;
resources 'bugtracker' => 'https://github.com/michal-josef-spacek/Plack-Middleware-Auth-Form-Tags-HTML/issues';
resources 'homepage' => 'https://github.com/michal-josef-spacek/Plack-Middleware-Auth-Form-Tags-HTML';
resources 'repository' => 'git://github.com/michal-josef-spacek/Plack-Middleware-Auth-Form-Tags-HTML';
test_requires 'Error::Pure' => 0;
test_requires 'File::Object' => 0;
test_requires 'HTTP::Request' => 0;
test_requires 'Plack::Test' => 0;
test_requires 'Test::More' => 0;
test_requires 'Test::NoWarnings' => 0;
tests_recursive;
version '0.01';

# Run.
WriteAll();
