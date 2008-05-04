package IWS::Schema::Team;

use strict;
use warnings;

use base qw/IWS::SchemaBase/;

my $CLASS = __PACKAGE__;

$CLASS->table('team');

$CLASS->add_columns(
    'pk1',
    { data_type => 'integer', size => '16', is_auto_increment => 1 },
    'token_name',
    { data_type => 'varchar', size => '255', is_nullable => 0 },
    'display_name',
    { data_type => 'varchar', size => '255', is_nullable => 0 },
);

$CLASS->set_primary_key('pk1');
$CLASS->add_unique_constraint( unique_token_name => [ 'token_name' ]);

$CLASS->belongs_to( 'league_links', 'IWS::Schema::League::Team', 
    { 'foreign.pk1' => 'self.pk1' } );
$CLASS->many_to_many( 'leagues', 'league_links', 'league' );

$CLASS->has_many( 'home_games', 'IWS::Schema::Game', 'team_pk1' );
$CLASS->has_many( 'away_games', 'IWS::Schema::Game', 'team_pk2' );
$CLASS->has_many( 'games', 'IWS::Schema::Game',
    [
        { 'foreign.team_pk1' => 'self.pk1' },
        { 'foreign.team_pk2' => 'self.pk1' },
    ]
);

1;
