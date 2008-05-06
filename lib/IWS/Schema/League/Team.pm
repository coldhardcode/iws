package IWS::Schema::League::Team;

use strict;
use warnings;

use base qw/IWS::Base::Schema::Base/;

my $CLASS = __PACKAGE__;

$CLASS->table('link_league_team');

$CLASS->add_columns(
    'league_pk1',
    { data_type => 'integer', size => '16', is_nullable => 0, is_foreign_key => 1 },
    'team_pk1',
    { data_type => 'integer', size => '16', is_nullable => 0, is_foreign_key => 1 },
);

$CLASS->set_primary_key(qw/league_pk1 team_pk1/);

$CLASS->belongs_to( 'league', 'IWS::Schema::League', 'league_pk1' );
$CLASS->belongs_to( 'team',   'IWS::Schema::Team',  'team_pk1' );

1;
