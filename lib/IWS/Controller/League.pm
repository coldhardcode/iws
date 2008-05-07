package IWS::Controller::League;

use strict;
use warnings;

use base 'Catalyst::Controller::REST::DBIC::Item';

use DateTime;
use DateTime::Format::MySQL;

__PACKAGE__->config(
    'default' => 'text/html',
    'map' => {
        'text/html' => [ 'View', 'TT' ],
        'text/xml'  => [ 'View', 'TT' ],
        'application/x-www-form-urlencoded' => 'JSON',
    },
    'class'    => 'Schema::League',
    'item_key' => 'token_name',
    'serialize_method' => 'serialize',
    'browser_serialize' => 0
);

=head1 NAME

IWS::Controller::League - Handle the various leagues

=head1 DESCRIPTION

This is somewhat of a loosely defined controller, since a league is any playing
series.  This means it includes various championships that mix clubs and other
friendly series.

=head1 METHODS

=cut

sub rest_base : Chained('.') PathPart('') CaptureArgs(0) { }

=head2 list_POST

Create a new league, insert it into the mix

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

    my $row = $c->model('Schema::League')->find_or_create({
        display_name => $display_name,
        token_name   => $token_name,
    });

    if ( $row ) {
        $self->status_created( $c,
            location => $c->uri_for(
                $c->controller->action_for('item'), [ $row->token_name ]
            )->as_string,
            entity => $row->serialize
        );
    } else {
        $self->status_bad_request( $c,
            message =>
                $c->localize(qq{Unable to create league, please check input})
        );
    }
}

=head1 item_base

We override the default item_base so that we can handle prefetching and only
show games that haven't finished

=cut

sub rest_item_base : Chained('rest_base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $identifier ) = @_;

    $c->stash->{rest}->{item} = $self->get_item($c, $identifier)->search(
        {
            'games.end_time' => { '>=', $c->stash->{now} }
        },
        {
            prefetch => {
                games => [
                    'home', 'visitor',
                    { broadcasts => 'network' }
                ]
            },
            order_by => [ 'games.start_time ASC' ]
        }
    )->single;
}

=head1 AUTHOR

J. Shirley C< <<jshirley@coldhardcode.com>> >

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
