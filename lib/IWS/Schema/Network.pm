package IWS::Schema::Network;

use strict;
use warnings;

use base qw/IWS::Base::Schema::Base/;

my $CLASS = __PACKAGE__;

$CLASS->table('network');

$CLASS->add_columns(
    'pk1',
    { data_type => 'integer', size => '16', is_auto_increment => 1 },
    'display_name',
    { data_type => 'varchar', size => '255', is_nullable => 0 },
    'token_name',
    { data_type => 'varchar', size => '255', is_nullable => 0 },
    'region_pk1',
    { data_type => 'integer', size => '16', is_nullable => 1 },
);

$CLASS->set_primary_key('pk1');
$CLASS->add_unique_constraint( unique_token_name => [ 'token_name' ]);

$CLASS->has_many( 'broadcasts', 'IWS::Schema::Game::Broadcast', 'network_pk1' );
$CLASS->many_to_many( 'games', 'broadcasts', 'game' );

1;
