package IWS::Controller::Team;

use strict;
use warnings;

use base 'Catalyst::Controller::REST::DBIC::Item';

use DateTime;

__PACKAGE__->config(
    'default' => 'text/html',
    'map' => {
        'text/html' => [ 'View', 'TT' ],
        'text/xml'  => [ 'View', 'TT' ],
        'application/x-www-form-urlencoded' => 'JSON',
    },
    'class'    => 'Schema::Team',
    'item_key' => 'token_name',
    'serialize_method' => 'serialize',
    'browser_serialize' => 0
);

sub rest_base : Chained('.') PathPart('') CaptureArgs(0) { }

=head2 list_POST

Add a new team into the system.

Required fields:

=over

=item display_name

The fully readable and presentable name of the team.

=back

Optional fields:

=over

=item token_name

 defaults to lc(display_name) with all non alnum chars replaced with -.

=back

=cut

sub rest_list_POST {
    my ( $self, $c ) = @_;

    my $data = $c->req->data;

    my $display_name = $data->{display_name};
    my $token_name   = $data->{token_name} || $display_name;
        $token_name = lc($token_name);
        $token_name =~ s/[^a-z0-9]/-/g;

    my $row = $self->get_rs( $c )->find_or_create({
        display_name => $display_name,
        token_name   => $token_name
    });

    if ( $row ) {
        $self->status_created( $c,
            location => $c->uri_for(
                $c->controller->action_for('team'), [ $row->token_name ]
            )->as_string,
            entity => $row->serialize
        );
    } else {
        $self->status_bad_request( $c,
            message =>
                $c->localize(qq{Unable to create team, please check input})
        );
    }
}

1;
