package Plack::Middleware::Auth::Form::Common;

use base qw(Plack::Middleware);
use strict;
use warnings;

use Error::Pure qw(err);
use Plack::Request;
use Plack::Response;
use Plack::Util::Accessor qw(after_logout app_form app_login_logged authenticator secure ssl_port);

our $VERSION = 0.01;

sub call {
	my ($self, $env) = @_;

	my $path = $env->{'PATH_INFO'};

	if ($env->{'psgix.session'}{'remember'}) {
		if ($path ne '/logout') {
			$env->{'psgix.session.options'}{'expires'} = time + 60 * 60 * 24 * 30;
		}
	}

	# Pages inside this middleware.
	if ($path eq '/login') {
		return $self->_login($env);
	} elsif ($path eq '/logout') {
		return $self->_logout($env);
	}

	# Logged, continue to application.
	if ($env->{'psgix.session'}{'user_id'}) {
		return $self->app->($env);

	# Redirect to login.
	} else {
		my $res = Plack::Response->new;
		$res->redirect('/login');
		return $res->finalize;
	}
}

sub prepare_app {
	my $self = shift;

	if (! defined $self->app_form) {
		err 'Missing application for form.';
	}

	if (! defined $self->app_login_logged) {
		err 'Missing application for login page if user is logged.';
	}

	if (! defined $self->authenticator) {
		err 'Authenticator is not set.';
	}
	my $auth = $self->authenticator;
	if (Scalar::Util::blessed($auth) && $auth->can('authenticate')) {

		# Because Authen::Simple barfs on 3 params.
		$self->authenticator(sub { $auth->authenticate(@_[0, 1]) });
	} elsif (ref $auth ne 'CODE') {
		err 'Authenticator should be a code reference or an object that responds to authenticate().';
	}

	return;
}

sub _login {
	my ($self, $env) = @_;

	delete $env->{'psgix.session'}{login_error};

	# Redirect to secured
	# XXX Move to middleware
	if ($self->secure
		&& (! defined $env->{'psgi.url_scheme'} || lc $env->{'psgi.url_scheme'} ne 'https')
		&& (! defined $env->{HTTP_X_FORWARDED_PROTO} || lc $env->{HTTP_X_FORWARDED_PROTO} ne 'https')) {

		my $server = $env->{HTTP_X_FORWARDED_FOR} || $env->{HTTP_X_HOST} || $env->{SERVER_NAME};
		my $secure_url = "https://$server".($self->ssl_port ? ':'.$self->ssl_port : '').$env->{PATH_INFO};
		return [
			301,
			['Location' => $secure_url],
			['Need a secure connection'],
		];
	}

	# Login action.
	if ($env->{REQUEST_METHOD} eq 'POST') {
		my $params = Plack::Request->new($env)->parameters;

		# Auth.
		my $auth_result = $self->authenticator->(
			$params->get('username'),
			$params->get('password'),
			$env,
		);

		# Auth result.
		my $error = 0;
		if (! $auth_result) {
			$env->{'psgix.session'}{login_error} = 'Wrong username or password.';
			$error = 1;
		} elsif (ref $auth_result) {
			if ($auth_result->{'error'}) {
				$env->{'psgix.session'}{login_error} = $auth_result->{'error'};
				$error = 1;
			} else {
				$env->{'psgix.session'}{user_id} = $auth_result->{'user_id'};
				$env->{'psgix.session'}{redir_to} = $auth_result->{redir_to};
			}
		} else {
			$env->{'psgix.session'}{user_id} = $params->get('username');
		}
		
		# Redirect after login.
		if (! $error) {
			$env->{'psgix.session.options'}->{change_id}++;
			$env->{'psgix.session'}{remember} = ($params->get('remember') ? 1 : 0);

			my $redir_to = delete $env->{'psgix.session'}{redir_to};
			if (URI->new($redir_to)->path eq $env->{PATH_INFO}) {
				$redir_to = '/';
			}

			return [
				302,
				['Location' => $redir_to],
				['Redirect'],
			];
		}

	# Logged.
	} elsif (defined $env->{'psgix.session'}{user_id}) {
		return $self->app_login_logged->($env);
	}

	$env->{'psgix.session'}{redir_to} ||= $env->{HTTP_REFERER} || '/';

	# Form app.
	return $self->app_form->($env);
}

sub _logout {
	my ($self, $env) = @_;

	# Delete session variables.
	delete $env->{'psgix.session'}{user_id};
	delete $env->{'psgix.session'}{remember};

	return [
		303,
		['Location' => $self->after_logout || '/' ],
		['After logout'],
	];
}

1;

__END__

