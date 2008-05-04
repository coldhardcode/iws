package IWS::Client;

use warnings;
use strict;

use base qw/Class::Accessor::Fast/;
use LWPx::ParanoidAgent;
use YAML::Syck;

use Carp;

__PACKAGE__->mk_accessors(qw/client server/);

my $SECRET = "Abracadabra";

sub new {
    my $class   = shift;
    my $server  = URI->new(shift);
    die "Server must be HTTP or HTTPS\n"
        unless $server and $server->scheme =~ /^http/;

    my $self    = bless { server => $server }, $class;

    $self->client( LWPx::ParanoidAgent->new );
    $self->client->whitelisted_hosts('127.0.0.1');

    return $self;
}

sub get_team {
    my ( $self, $team ) = @_;
    my $uri = $self->server->clone;
    if ( ref $team and $team->{token_name} ) {
        $uri->path("/team/-/$team->{token_name}"); 
    }
    elsif ( not ref $team ) {
        $uri->path("/team/-/$team"); 
    } else {
        carp "Unable to get_team without a token name\n";
    }
    
    my $res = $self->client->get( "$uri",
        'X-Token'       => $SECRET,
        'Content-type'  => 'text/x-yaml'
    );

    if ( $res->is_success ) {
        my $data = YAML::Syck::Load($res->content);
        return $data->{team} if $data->{team};
        carp "Unable to fetch team $team: unknown error\n";
        return undef;
    }

    carp "Unable to fetch team $team: " . $res->status_line . "\n";
    return undef;
}

sub add_team {
    my ( $self, $team ) = @_;
    return undef unless ref $team;

    my $uri = $self->server->clone;
    $uri->path("/team/"); 
    my $res = $self->client->post( "$uri",
        'X-Token'       => $SECRET,
        'Content-type'  => 'text/x-yaml',
        Content => YAML::Syck::Dump($team)
    );
    if ( $res->is_success ) {
        return YAML::Syck::Load($res->content);
    }
    carp "Unable to create team $team: " . $res->status_line . "\n";
    return undef;
}

sub get_league {
}

sub add_league {
    my ( $self, $team ) = @_;
    return undef unless ref $team;

    my $uri = $self->server->clone;
    $uri->path("/league/"); 
    my $res = $self->client->post( "$uri",
        'X-Token'       => $SECRET,
        'Content-type'  => 'text/x-yaml',
        Content         => YAML::Syck::Dump($team)
    );
    if ( $res->is_success ) {
        return YAML::Syck::Load($res->content);
    }
    carp "Unable to create game $team: " . $res->status_line . "\n";
    return undef;

}

sub get_network {

}

sub add_network {
    my ( $self, $network ) = @_;
    return undef unless ref $network;

    my $uri = $self->server->clone;
    $uri->path("/network/"); 
    my $res = $self->client->post( "$uri",
        'X-Token'       => $SECRET,
        'Content-type'  => 'text/x-yaml',
        Content         => YAML::Syck::Dump($network)
    );
    if ( $res->is_success ) {
        return YAML::Syck::Load($res->content);
    }
    carp "Unable to create network: " . $res->status_line . "\n";
    return undef;
}

sub get_game {
}

sub add_game {
    my ( $self, $game ) = @_;
    return undef unless ref $game;

    my $uri = $self->server->clone;
    $uri->path("/game/"); 

    my $res = $self->client->post( "$uri",
        'X-Token'       => $SECRET,
        'Content-type'  => 'text/x-yaml',
        Content         => YAML::Syck::Dump($game)
    );

    if ( $res->is_success ) {
        return YAML::Syck::Load($res->content);
    }

    carp "Unable to create game: " . $res->status_line . "\n" . $res->content . "\n";

    return undef;
}

sub add_broadcast {
    my ( $self, $game, $data ) = @_;
    my $game_pk1 = ref $game eq 'HASH' ? $game->{pk1} : $game;
    die "Game PK1 looks suspect: $game_pk1 should be a positive integer"
        unless int($game_pk1) > 0;

    my $uri = $self->server->clone;
    $uri->path("/game/$game_pk1/broadcast"); 

    my $res = $self->client->post( "$uri",
        'X-Token'       => $SECRET,
        'Content-type'  => 'text/x-yaml',
        Content         => YAML::Syck::Dump($data)
    );

    if ( $res->is_success ) {
        return YAML::Syck::Load($res->content);
    }

    carp "Unable to create broadcast: " . $res->status_line . "\n";

    return undef;

}

1;
