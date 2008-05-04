package IWS::Map::League;

my %MAPS = (
    "Int'l Soccer"   => "International Soccer",
    "International Soccer" => {
        display_name    => 'International Soccer',
        token_name      => "intl"
    },

    "Premier League" => {
        display_name    => 'English Premier League',
        token_name      => "premier_league"
    },
    "MISL" => {
        display_name    => 'MISL',
        token_name      => "misl"
    },
    "La Liga" => {
        display_name    => 'La Liga',
        token_name      => "la_liga"
    },
    'UEFA Champions League' => {
        display_name    => 'UEFA Champions League',
        token_name      => "uefa_cup"
    },
    'Copa Campeones de Centroamerica' => {
        display_name => 'Copa Campeones de Centroamerica',
        token_name   => 'central_america_cup'
    },
);

sub check {
    my ( $class, $league ) = @_;
    return $league if ref $league;

    return $class->check($MAPS{$league}) if exists $MAPS{$league};
    my $token = lc($league);
        $token =~ s/[^a-z]/_/g;
    return { display_name => $league, token_name => $token };
}


1;

