package Catalyst::Action::REST::Deserialize::Form;

use strict;
use warnings;

use base 'Catalyst::Action';

sub execute {
    my $self = shift;
    my ( $controller, $c ) = @_;

    $c->req->data( $c->req->params );
    $c->log->debug("Deserializing...");
    return $self->next::method(@_);
}

1;
