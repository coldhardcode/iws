#!/usr/bin/perl

use List::Util qw|sum|;
use YAML::Syck;
use JSON::Syck qw(Dump);

use Data::Dump qw(dump);

my $data = YAML::Syck::LoadFile($ARGV[0]);

my %tz_layers = ();
my @places;

foreach my $country ( keys %$data ) {

    foreach my $tz ( keys %{$data->{$country}} ) {
        my $d = $data->{$country}->{$tz};

        my @tz_names = split('/', $tz);

        my $parent = \%tz_layers;

        while ( my $tz_name = shift @tz_names ) {
            $parent->{$tz_name} ||= {};
            $parent = $parent->{$tz_name};
        }
        $parent->{coord} = 
            [ @{ $d->{Point}->{coordinates} }[0 .. 1] ];
        $parent->{address} = $d->{address};
    }
}

set_averages_depth_first(\%tz_layers);

sub set_averages_depth_first {
    my $layer = shift;
   
    return if $layer->{coord};
    
    my @avg_lat = ();
    my @avg_lng = ();

    foreach my $key ( keys %$layer ) {
        set_averages_depth_first($layer->{$key});
        push @avg_lat, $layer->{$key}->{coord}->[1]; 
        push @avg_lng, $layer->{$key}->{coord}->[0]; 
    }
    $layer->{coord} = [ ( sum @avg_lat ) / @avg_lat, ( sum @avg_lng ) / @avg_lng ];
}

print Dump(\%tz_layers);
exit;

