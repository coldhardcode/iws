package IWS::Controller::Game;

use strict;
use warnings;

use base 'Catalyst::Controller::REST::DBIC::Item';

use DateTime;
use DateTime::Format::RSS;
use DateTime::Format::MySQL;

my $dt_parser = DateTime::Format::RSS->new;

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

    $c->stash->{page}->{name} = $c->localize("Upcoming Games");

    my $filter = {};

    if ( my $team = $c->req->params->{team} ) {
        my $struct = [];
        if ( $team =~ /^(\d+)$/ ) {
            push @$struct,
             { 'me.team_pk1' => $1 },
             { 'me.team_pk2' => $1 };
        } else {
            push @$struct,
             { 'home.token_name' => $team },
             { 'visitor.token_name' => $team };
        }
        $filter->{'-or'} = $struct;
    } else {
        if ( my $team_pk1 = $c->req->params->{home} ) {
            if ( $team_pk1 =~ /^(\d+)$/ ) {
                $filter->{'me.team_pk1'} = $1;
            } else {
                $filter->{'home.token_name'} = $team_pk1;
            }
        }

        if ( my $team_pk2 = $c->req->params->{visitor} ) {
            if ( $team_pk2 =~ /^(\d+)$/ ) {
                $filter->{'me.team_pk2'} = $1;
            } else {
                $filter->{'visitor.token_name'} = $team_pk2;
            }
        }
    }

    $filter->{'me.start_time'} = { '>=' => DateTime->now };
    my $rs = $c->model('Schema::Game')->search(
        $filter,
        {
            #join => [ qw/home visitor/ ],
            prefetch => [
                qw/home visitor league/, { broadcasts => 'network' } ],
            order_by => [ 'me.start_time ASC' ],
            rows     => 20
        }
    );

    $self->status_ok( $c,
        entity => {
            #games => $rs->serialize
            games => [ $rs->all ]
        }
    );
}

=head2 list_POST

Create a new game, insert it into the mix

Required fields:

    home:       $team_token
    visitor:    $team_token
    league:     $league_token
    start_time: 2007-12-22T03:18:10 - UTC!
    end_time:   2007-12-22T03:18:10 - UTC!

=cut

sub list_POST {
    my ( $self, $c ) = @_;

    my $data = $c->req->data;
    my $teams = $c->model('Schema::Team')->search(
        { token_name => [ $data->{home}, $data->{visitor} ] }
    );

    my $league;

    if ( $data->{league} ) {
        $league = $c->model('Schema::League')->search(
            { token_name => $data->{league} }
        )->first;
        $c->log->debug("Got league? " . ( $league ? $league->pk1 : "nope :(" ) )
            if $c->debug;
    }
    
    # Bogus teams.  Bogus!
    if ( $teams->count != 2 ) {
        return $self->status_bad_request( $c,
            message => $c->localize('Unable to create game, invalid teams')
        );
    }

    my $start_time = $dt_parser->parse_datetime($data->{start_time});
    my $end_time   = $dt_parser->parse_datetime($data->{end_time});

    unless ( $start_time and $end_time and
         ( my $res = DateTime->compare($start_time, $end_time) ) == -1 )
    {
        return $self->status_bad_request( $c,
            message => $c->localize("Invalid start and end time ([_1])", $res)
        );
    }

    my @team_list = $teams->all;
    my ( $home )    = grep { $_->token_name eq $data->{home} } @team_list;
    my ( $visitor ) = grep { $_->token_name eq $data->{visitor} } @team_list;

    # First, lets search to see if there is a game that is on that day.
    # If there is, chances are it is a dupe... just return that game
    my $check_date = $start_time->clone;
        $check_date->set( hour => 0, minute => 0, second => 0 );
    my $check_date_end = $check_date->clone;
        $check_date_end->add( days => 1 );

    my $dupe_rs = $c->model('Schema::Game')->search(
        {
            team_pk1    => $home->pk1,
            team_pk2    => $visitor->pk1,
            start_time  => {
                -between => [
                    map { DateTime::Format::MySQL->format_datetime($_); }
                    ( $check_date, $check_date_end )
                ]
            }
        }
    );

    my $row;
    if ( $dupe_rs->count > 0 ) {
        $row = $dupe_rs->first;
    } else {
        $row = $c->model('Schema::Game')->find_or_create({
                home        => $home,
                visitor     => $visitor,
                league_pk1  => $league ? $league->pk1 : undef,
                start_time  => $start_time,
                end_time    => $end_time,
            });
    }
    if ( $row ) {
        $c->log->debug("Created game " . $row->pk1) if $c->debug;
        return $self->status_created( $c,
            location => $c->uri_for(
                $c->controller->action_for('game'), [ $row->pk1 ]
            )->as_string,
            #SER: entity => $row->serialize
            entity => $row->serialize
        );
    } else {
        $c->log->error("Unable to create game in database");
        return $self->status_bad_request( $c,
            message =>
                $c->localize(qq{Unable to create game, please check input})
        );
    }

}

sub game_base : Chained('base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $pk1 ) = @_;

    my $rs = $c->model('Schema::Game')->search(
        { 'me.pk1' => $pk1 },
        { prefetch => [ qw/home visitor broadcasts/ ] }
    );

    $c->stash->{rs}->{game} = $rs;

    # 404 condition, not found
    if ( $rs->count == 0 ) {
        $self->status_not_found( $c,
            message => $c->localize('Sorry, the game requested cannot be found')
        );
        $c->detach;
    }

    $c->stash->{game} = $rs->first;
}

sub game : Chained('game_base') PathPart('') Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;
}

sub game_GET {
    my ( $self, $c ) = @_;

    $self->status_ok( $c,
        #SER: entity => { game => $c->stash->{game}->serialize }
        entity => { game => $c->stash->{game} }
    );
}

sub broadcast : Chained('game_base') Args(0) : ActionClass('REST') {
    my ( $self, $c ) = @_;
}

sub broadcast_GET {
    my ( $self, $c ) = @_;

    $self->status_ok( $c,
        entity => {
            #SER: broadcasts => $c->stash->{game}->broadcasts->serialize
            broadcasts => [ $c->stash->{game}->broadcasts->all ]
        }
    );
}

=head2 broadcast_POST

Add a broadcast for the currently loaded game

Required Fields:
    
    network: $network_token

Optional Fields:

    start_time: # defaults to game.start_time
    end_time:   # defaults to game.end_time

=cut

sub broadcast_POST {
    my ( $self, $c ) = @_;

    my $data = $c->req->data;
    my $game = $c->stash->{game};

    unless ( $data->{network} ) {
        return $self->status_bad_request( $c,
            message => $c->localize('Unable to create broadcast, need network')
        );
    }

    my ( $start_time, $end_time );
    if ( $data->{start_time} and $data->{end_time} ) {
        $c->log->debug("Parsing $data->{start_time} and $data->{end_time}")
            if $c->debug;
        $start_time = $dt_parser->parse_datetime( $data->{start_time} );
        $end_time   = $dt_parser->parse_datetime( $data->{end_time} );
    } else {
        $start_time = $game->start_time;
        $end_time   = $game->end_time;
    }
    unless ( $start_time and $end_time ) {
        return $self->status_bad_request( $c,
            message => $c->localize('Unable to create broadcast, invalid times')
        );
    }

    my $network_rs = $c->model('Schema::Network')
        ->search({ token_name => $data->{network} });
   
    if ( $network_rs->count != 1 ) {
        return $self->status_bad_request( $c,
            message => $c->localize('Unable to create broadcast, invalid network')
        );
    }

    my $network = $network_rs->first;
    my $row = $game->broadcasts->find_or_create({
        network_pk1 => $network->pk1,
        start_time  => $start_time,
        end_time    => $end_time,
    });

    if ( $row ) {
        $self->status_created( $c,
            location => $c->uri_for(
                $c->controller->action_for('broadcast_item'),
                [ $game->pk1, $row->pk1 ]
            )->as_string,
            entity => $row->serialize
            #entity => $row # FIXME - circ ref dies 
        );
    } else {
        $self->status_bad_request( $c,
            message =>
                $c->localize(qq{Unable to create broadcast, please check input})
        );
    }
}

sub broadcast_PUT {
    my ( $self, $c ) = @_;
}

sub broadcast_base : Chained('game_base') PathPart('broadcast') CaptureArgs(1) {
    my ( $self, $c, $pk1 ) = @_;
    $c->stash->{rs}->{broadcast} =
        $c->stash->{game}->broadcasts({ pk1 => $pk1 });
}

sub broadcast_item : Chained('broadcast_base') PathPart('') Args(0) ActionClass('REST') {
    my ( $self, $c ) = @_;

    if ( $c->stash->{rs}->{broadcast}->count != 1 ) {
        return $self->status_not_found( $c,
            message => $c->localize('Sorry, the broadcast requested cannot be found')
        );
    }
    $c->stash->{broadcast} = $c->stash->{rs}->{broadcast}->first;
}

sub broadcast_item_GET {
    my ( $self, $c ) = @_;
    $self->status_ok( $c,
        entity => {
            #SER: broadcast => $c->stash->{broadcast}->serialize
            broadcast => $c->stash->{broadcast}
        }
    );
}

sub broadcast_item_DELETE {
    my ( $self, $c ) = @_;
    $c->stash->{broadcast}->delete;
    $self->status_ok( $c, entity => $c->localize('Broadcast deleted') );
}


=head2 game_PUT

Updates an existing game in the system.

Required fields:

    home:       $team_token
    visitor:    $team_token
    start_time:
    end_time:

=cut

sub game_PUT {
    my ( $self, $c ) = @_;

}

1;
