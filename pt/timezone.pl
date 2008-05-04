#!/usr/bin/perl

use warnings;
use strict;

use DateTime;
use DateTime::TimeZone;
use Geo::Coder::Google;

use YAML::Syck qw(Dump);
use Data::Dump qw(dump);

srand(time ^ $$);

my $geocoder = Geo::Coder::Google->new( apikey => qq/ABQIAAAAh3LqwY1XU3ldEkDJBxe4hBRhLfGjC1nDpTV6HxB8ORgBxMcLgBTx-CJQkXOhmrjV-ZJ7G1SzQGiHEg/ );

my $loc = {};

foreach my $cat ( DateTime::TimeZone->countries ) {
    #print "\n***\n$cat\n***\n";
    foreach my $name ( DateTime::TimeZone->names_in_country( $cat ) ) {
        my @country  = split('/', $name);
        shift @country;
        unshift @country, $cat;
        my $f_name = join(", ", map { s/_/ /g; $_; } reverse @country);
        warn "Geocode: $f_name\n";
        my $location = $geocoder->geocode( location => $f_name );
        unless ( $location ) {
            shift @country;
            $f_name = join(", ", map { s/_/ /g; $_; } reverse @country);
            $location = $geocoder->geocode( location => $f_name );
        }
        unless ( $location ) {
            warn "Can't geocode $f_name\n";
            next;
        }
        $loc->{$cat}->{$name} = $location;
        sleep( 2 + rand(5) );
    }
}

print Dump( $loc );
