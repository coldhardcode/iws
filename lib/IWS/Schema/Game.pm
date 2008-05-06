package IWS::Schema::Game;

use strict;
use warnings;

use base qw/IWS::Base::Schema::Base/;

my $CLASS = __PACKAGE__;

$CLASS->table('game');

$CLASS->add_columns(
    'pk1',
    { data_type => 'integer', size => '16', is_auto_increment => 1 },
    'league_pk1',
    { data_type => 'integer', size => '16', is_nullable => 0, is_foreign_key => 1 },
    'team_pk1',
    { data_type => 'integer', size => '16', is_nullable => 0, is_foreign_key => 1 },
    'team_pk2',
    { data_type => 'integer', size => '16', is_nullable => 0, is_foreign_key => 1 },
    'start_time',
    { data_type => 'datetime', is_nullabe => 0 },
    'end_time',
    { data_type => 'datetime', is_nullabe => 0 },
);
$CLASS->set_primary_key('pk1');

$CLASS->belongs_to( 'home', 'IWS::Schema::Team', 'team_pk1' );
$CLASS->belongs_to( 'visitor', 'IWS::Schema::Team', 'team_pk2' );
$CLASS->belongs_to( 'league', 'IWS::Schema::League', 'league_pk1' );

$CLASS->has_many( 'broadcasts', 'IWS::Schema::Game::Broadcast', 'game_pk1' );
$CLASS->many_to_many( 'networks', 'broadcasts', 'network' );

sub _serialize_rels {
    qw/home visitor broadcasts/
}

1;
