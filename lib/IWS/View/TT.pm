package IWS::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    PRE_PROCESS        => 'site/shared/base.tt',
    WRAPPER            => 'site/wrapper.tt',
    TEMPLATE_EXTENSION => '.tt',
    TIMER              => 0,
    static_root        => '/static',
    static_build       => 0
});

sub template_vars {
    my $self = shift;
    return (
        $self->NEXT::template_vars(@_),
        static_root  => $self->{static_root},
        static_build => $self->{static_build}
    );
}

sub process {
    my ( $self, $c ) = ( shift, shift );
    if ( $c->res->content_type eq 'text/xml' ) {
        $c->res->content_type('text/html');
    }
    $self->NEXT::process($c, @_);
}

=head1 NAME

IWS::View::TT - Catalyst TT::Bootstrap View

=head1 SYNOPSIS

See L<IWS>

=head1 DESCRIPTION

Catalyst TT::Bootstrap View.

=head1 AUTHOR

J. Shirley,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
