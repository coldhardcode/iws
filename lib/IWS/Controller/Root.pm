package IWS::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

IWS::Controller::Root - Root Controller for IWS

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    $c->res->status(404);
    $c->res->body(q{Sorry, nothing found});
}

sub base : Chained('/') PathPart('') CaptureArgs(0) { 
    my ( $self, $c ) = @_;
    $c->languages( [ 'en' ] );
    $c->stash->{now} = DateTime->now;
    $c->stash->{default_tz} ||=
        ( $c->config->{defaults}->{timezone} || 'America/New_York' );

    $c->log->debug("TZ: $c->stash->{default_tz}") if $c->debug;

    if ( $c->req->method eq 'POST' ) {
        unless ( $c->req->header('X-Token') eq $c->config->{secret} ) {
            $c->res->status(403);
            $c->res->body('Nein!');
            $c->detach;
        }
    }
}

sub root : Chained('base') PathPart('') Args(0) {
    my ( $self, $c ) = @_;
    $c->res->redirect( $c->uri_for( $c->controller('Game')->action_for('list') ) );
}


sub game    : Chained('base') PathPart('game') CaptureArgs(0) { }
sub team    : Chained('base') PathPart('team') CaptureArgs(0) { }
sub league  : Chained('base') PathPart('league') CaptureArgs(0) { }
sub network : Chained('base') PathPart('network') CaptureArgs(0) { }
sub search  : Chained('base') PathPart('search') CaptureArgs(0) { }

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

J. Shirley,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
