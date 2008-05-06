package IWS;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

# Custom Serializers
use Catalyst::Action::REST::Deserialize::Form;
use Catalyst::Action::REST::Serialize::Form;

use Catalyst qw/
    ConfigLoader Static::Simple
    I18N
/;

our $VERSION = '0.01003';

__PACKAGE__->config(
    name => 'IWS'

);

__PACKAGE__->setup;

__PACKAGE__->request_class( 'Catalyst::Request::REST::ForBrowsers' );
=head1 NAME

IWS - Catalyst based application for soccer lovers everywhere

=head1 SYNOPSIS

    script/iws_server.pl

=head1 DESCRIPTION

This powers the iwatchsoccer.com website.

This is a Cold Hard Code production

=head1 SEE ALSO

L<IWS::Controller::Root>, L<Catalyst>

=head1 AUTHOR

J. Shirley C< <<jshirley@coldhardcode.com>> >

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
