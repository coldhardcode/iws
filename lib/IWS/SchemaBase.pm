package IWS::SchemaBase;

use Carp;
use IWS::ResultSet::Serialize;

use warnings;
use strict;

use base qw/DBIx::Class/;

my $CLASS = __PACKAGE__;

$CLASS->load_components(qw|TimeStamp Core|);

sub table {
    my $class = shift;
    $class->next::method(@_);
    $class->resultset_class('IWS::ResultSet::Serialize');
}

sub serialize {
    my ( $self, @filter_rels ) = @_;

    my %data = $self->get_columns;

    my %map;

    if ( $filter_rels[0] and ref $filter_rels[0] eq 'HASH' ) {
        %map = %{ $filter_rels[0] };
    } elsif ( @filter_rels ) {
        %map = map { $_ => $_ } @filter_rels;
    }

    if ( $self->can("_serialize_rels") ) {
        my @rels = $self->_serialize_rels;
        foreach my $rel ( @rels ) {
            next if keys %map and not exists $map{$rel};
            my @p = ref $map{$rel} eq 'ARRAY' ? @{ $map{$rel} } : ();
            my $d;
            eval {
                $d = $self->$rel(@p)->serialize;
            };
            if ( $@ ) { carp $@; }
            $data{$rel} = $d;
        }
    }

    return { %data };
}

1;
