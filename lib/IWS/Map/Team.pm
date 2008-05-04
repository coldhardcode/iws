package IWS::Map::Team;

my %MAPS = (
    'Man United'        => 'Manchester United',
    'Man. United'       => 'Manchester United',
    'Man. Utd'          => 'Manchester United',
    'Man. Utd.'         => 'Manchester United',
    'Manchester Utd.'   => 'Manchester United',
    'Milan'             => 'AC Milan',
    'Celtic'            => 'Celtic FC',
);

sub check {
    my ( $class, $team ) = @_;

    return exists $MAPS{$team} ? $class->check($MAPS{$team}) : $team;
}

1;

