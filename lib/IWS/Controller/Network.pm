package IWS::Controller::Network;

use strict;
use warnings;
use base 'Catalyst::Controller::REST';

__PACKAGE__->config(
    'default' => 'text/html',
    'map' => {
        'text/html' => [ 'View', 'TT' ],
        'text/xml'  => [ 'View', 'TT' ],
        'application/x-www-form-urlencoded' => 'JSON',
    },
);

=head1 NAME

IWS::Controller::Network - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub base : Chained('.') PathPart('') CaptureArgs(0) { }

sub list : Chained('base') PathPart('') Args(0) ActionClass('REST') { }

sub list_GET {
    my ( $self, $c ) = @_;

    my $rs = $c->model('Schema::Network')->search();

    $self->status_ok( $c,
        entity => {
            networks => $rs->serialize
        }
    );
}

=head2 list_POST

Create a new network, insert it into the mix

Required fields:

    display_name

Optional fields:
    token_name: defaults to lc(display_name) with all non alnum chars replaced
                with underscore

=cut

sub list_POST {
    my ( $self, $c ) = @_;

    my $data = $c->req->data;

    my $display_name = $data->{display_name};
    my $token_name   = $data->{token_name} || $display_name;
        $token_name = lc($token_name);
        $token_name =~ s/[^a-z0-9]/_/g;

    my $row = $c->model('Schema::Network')->find_or_create({
        display_name => $display_name,
        token_name   => $token_name
    });

    if ( $row ) {
        $self->status_created( $c,
            location => $c->uri_for(
                $c->controller->action_for('network'), [ '-', $row->token_name ]
            )->as_string,
            entity => $row->serialize
        );
    } else {
        $self->status_bad_request( $c,
            message =>
                $c->localize(qq{Unable to create network, please check input})
        );
    }
}

sub item_base : Chained('base') PathPart('') CaptureArgs(2) {
    my ( $self, $c, $is_id, $ident ) = @_;
    my $filter = {};
    if ( $is_id eq '-' ) {
        $filter->{'me.token_name'} = $ident;
    } else {
        $filter->{'me.pk1'} = int($ident);
    }
    $c->stash->{rs}->{item} = $c->model("Schema::Network")->search($filter);
}

sub item : Chained('item_base') PathPart('') Args(0) ActionClass('REST') {
}

sub item_GET {
    my ( $self, $c ) = @_;
    my $row = $c->stash->{rs}->{item}->first;

    if ( $row ) {
        $c->log->debug("Fetched row: " . $row->pk1);
        $c->stash->{network} = $row;
        $self->status_ok( $c,
            entity => { network => $row }
        );
    } else {
        $self->status_bad_request( $c,
            message =>
                $c->localize(qq{Unable to find network, please check input})
        );
    }
}


=head1 AUTHOR

J. Shirley,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
