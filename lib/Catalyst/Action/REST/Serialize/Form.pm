package Catalyst::Action::REST::Serialize::Form;

use strict;
use warnings;

use base 'Catalyst::Action';

sub execute {
    my ( $self, $controller, $c ) = @_;
    my $stash_key = $controller->config->{'serialize'}->{'stash_key'} || 'rest';
    my $rest_data = $c->stash->{$stash_key};

    if ( ref $rest_data eq 'HASH' ) {
        $c->stash->{form} = _rest_to_form($rest_data);
    }

    return $self->next::method(@_);
}

sub _rest_to_form {
    my ( $rest ) = @_;
    return undef unless ref $rest eq 'HASH';
    my $form = {};
    foreach my $key ( keys %$rest ) {
        if ( ref $rest->{$key} ) {
            $form->{$key} = _rest_to_form($rest->{$key});
        } else {
            $form->{$key} = $rest->{$key};
        }
    }

    return $form;
}

1;
