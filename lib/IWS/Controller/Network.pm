package IWS::Controller::Network;

use strict;
use warnings;

use base 'Catalyst::Controller::REST::DBIC::Item';

__PACKAGE__->config(
    'default' => 'text/html',
    'map' => {
        'text/html' => [ 'View', 'TT' ],
        'text/xml'  => [ 'View', 'TT' ],
        'application/x-www-form-urlencoded' => 'JSON',
    },
    'class'    => 'Schema::Network',
    'item_key' => 'token_name',
    'serialize_method' => 'serialize',
    'browser_serialize' => 0
);

=head1 NAME

IWS::Controller::Network - The Network items

=head1 DESCRIPTION

The Networks.  The beloved television networks that broadcast soccer to the
swarms of rabid fans.

=head1 METHODS

=cut

sub rest_base : Chained('.') PathPart('') CaptureArgs(0) { }

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

=head1 AUTHOR

J. Shirley C< <<jshirley@coldhardcode.com>> >

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
