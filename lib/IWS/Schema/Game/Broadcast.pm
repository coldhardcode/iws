package IWS::Schema::Game::Broadcast;

use strict;
use warnings;

use base qw/IWS::SchemaBase/;

my $CLASS = __PACKAGE__;

$CLASS->table('game_broadcast');

$CLASS->add_columns(
    'pk1',
    { data_type => 'integer', size => '16', is_auto_increment => 1 },
    'game_pk1',
    { data_type => 'integer', size => '16', is_nullable => 0, is_foreign_key => 1 },
    'network_pk1',
    { data_type => 'integer', size => '16', is_nullable => 0, is_foreign_key => 1 },
    'start_time',
    { data_type => 'datetime', is_nullabe => 0 },
    'end_time',
    { data_type => 'datetime', is_nullabe => 0 },
);

$CLASS->set_primary_key('pk1');

$CLASS->belongs_to( 'network', 'IWS::Schema::Network', 'network_pk1' );
$CLASS->belongs_to( 'game', 'IWS::Schema::Game', 'game_pk1' );

sub _serialize_rels {
    qw/network/
}

1;
