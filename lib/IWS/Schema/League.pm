package IWS::Schema::League;

use strict;
use warnings;

use base qw/IWS::Base::Schema::Base/;

my $CLASS = __PACKAGE__;

$CLASS->table('league');

$CLASS->add_columns(
    'pk1',
    { data_type => 'integer', size => '16', is_auto_increment => 1 },
    'display_name',
    { data_type => 'varchar', size => '255', is_nullable => 0 },
    'token_name',
    { data_type => 'varchar', size => '255', is_nullable => 0 },
);

$CLASS->set_primary_key('pk1');
$CLASS->add_unique_constraint( unique_token_name => [ 'token_name' ]);

$CLASS->has_many( 'team_links', 'IWS::Schema::League::Team', 'team_pk1' );
$CLASS->many_to_many( 'teams', 'team_links', 'team' );

$CLASS->has_many( 'games', 'IWS::Schema::Game', 'league_pk1' );

sub _serialize_rels {
    return qw/games/;
}

1;
