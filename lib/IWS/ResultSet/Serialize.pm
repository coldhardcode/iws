package IWS::ResultSet::Serialize;

use strict;
use warnings;

use base 'DBIx::Class::ResultSet';
use DBIx::Class::ResultClass::HashRefInflator;

sub serialize {
    my ( $self ) = @_;

    #$new_rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

    #return $new_rs->all;
    my $new_rs = $self->search;
    return [
        map {
            $_->can("serialize") ? $_->serialize : { $_->get_columns }
        }
        $new_rs->all
    ];
}

1;

