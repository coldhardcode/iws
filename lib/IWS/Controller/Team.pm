package IWS::Controller::Team;

use strict;
use warnings;

use base 'Catalyst::Controller::REST';

use DateTime;

__PACKAGE__->config(
    'default' => 'text/html',
    'map' => {
        'text/html' => [ 'View', 'TT' ],
        'text/xml'  => [ 'View', 'TT' ],
        'application/x-www-form-urlencoded' => 'JSON',
    },
);

sub base : Chained('.') PathPart('') CaptureArgs(0) { }

sub list : Chained('base') PathPart('') Args(0) ActionClass('REST') { }

sub list_GET {
    my ( $self, $c, $pk1 ) = @_;

    my $rs = $c->model('Schema::Team')->search();
    $self->status_ok( $c,
        entity => {
            teams => $rs->serialize
        }
    );
}

=head2 list_POST

Add a new team into the system.

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

    my $row = $c->model('Schema::Team')->find_or_create({
        display_name => $display_name,
        token_name   => $token_name
    });

    if ( $row ) {
        $self->status_created( $c,
            location => $c->uri_for(
                $c->controller->action_for('team'), [ '-', $row->token_name ]
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

sub team_base : Chained('base') PathPart('') CaptureArgs(2) {
    my ( $self, $c, $filter, $pk1 ) = @_;

    my $data = $filter eq 'id' ?
        { 'pk1' => $pk1 } : { 'token_name' => $pk1 };
    my $rs = $c->model('Schema::Team')->search($data);
    $c->stash->{rs}->{team} = $rs;
}

sub team : Chained('team_base') PathPart('') Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;
}

sub team_GET {
    my ( $self, $c ) = @_;
    my $rs = $c->stash->{rs}->{team};
    delete $c->stash->{rs};

    # 404 condition, not found
    if ( $rs->count == 0 ) {
        $self->status_not_found( $c,
            message => $c->localize('Sorry, the team requested cannot be found')
        );
    } else {
        $self->status_ok( $c,
            entity => {
                team => $rs->first
            }
        );
    }
}

1;
