#!/usr/bin/perl -w

BEGIN { $ENV{CATALYST_ENGINE} ||= 'SCGI' }

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use FindBin;
use lib "$FindBin::Bin/../lib";
use IWS;

my $help = 0;
my ( $listen, $nproc, $pidfile, $manager, $detach, $keep_stderr );
 
GetOptions(
    'help|?'      => \$help,
    'listen|l=s'  => \$listen,
    'keeperr|e'   => \$keep_stderr,
);

pod2usage(1) if $help;

IWS->run( 
    $listen, 
    {
        keep_stderr => $keep_stderr,
    }
);

1;

=head1 NAME

iws_scgi.pl - Catalyst SCGI

=head1 SYNOPSIS

iws_scgi.pl [options]
 
 Options:
   -? -help      display this help and exits
   -l -listen    Socket path to listen on
                 (defaults to standard input)
                 can be HOST:PORT, :PORT or a
                 filesystem path
   -e -keeperr   send error messages to STDOUT, not
                 to the webserver

=head1 DESCRIPTION

Run a Catalyst application under SCGI.

=head1 AUTHOR

J. Shirley, C<jshirley@cpan.org>
Maintained by the Catalyst Core Team.

=head1 COPYRIGHT

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
