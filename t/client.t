use strict;
use warnings;

use DateTime;
use Test::More tests => 8;
use Data::Dump qw(dump);
BEGIN { use_ok 'IWS::Client'; }

my $client = IWS::Client->new('http://127.0.0.1:4000');
isa_ok($client, 'IWS::Client', 'Created client');

my $team = $client->get_team('la_galaxy');

if ( $team ) {
    ok($team, 'got team');
} else {
    $team = $client->add_team({ display_name => 'LA Galaxy', token_name => 'la_galaxy' });

}
print dump($team);

my $copy = { %$team };
delete $copy->{pk1};
is_deeply($copy, { token_name => 'la_galaxy', display_name => 'LA Galaxy' }, 'got LA Galaxy');

my $new_team = $client->add_team({ display_name => 'Inter Milan' });
ok($new_team, "Created new team");
is($new_team->{token_name}, 'inter_milan', "Created new team token");

my $network = $client->add_network({
    display_name => 'Fox Soccer Channel',
    token_name => 'fsc'
});
ok($network, "Created network (FSC)");
is($network->{token_name}, 'fsc', "Created FSC token");

my $league = $client->add_league( { display_name => 'English Premier League', token_name => 'premier_league' } );
ok($league, "Created league");

my $game = $client->add_game({
    home        => 'la_galaxy',
    visitor     => 'houston_dynamo',
    league      => $league->{token_name},
    start_time  => DateTime->now->add( days => 1 )->strftime("%a, %d %b %Y %H:%M:%S %z"),
    end_time    => DateTime->now->add( days => 1, hours => 2)->strftime("%a, %d %b %Y %H:%M:%S %z"),
});

ok($game, "Created game");

my $broadcast = $client->add_broadcast( $game, { network => $network->{token_name} } );
ok($broadcast, "Created broadcast");

