#!/usr/bin/perl

use FindBin;
use lib qq($FindBin::Bin/../lib);

use IWS;

use Pod::Usage;
use Getopt::Long;

my ( $help, $deploy, $ddl ) = ( 0, 0, 0 );

GetOptions(
    'help|?'    => \$help,
    'deploy|d'  => \$deploy,
    'ddl'       => \$ddl,
);

pod2usage(1) if $help;

my $schema = IWS->model('Schema')->schema;

if ( $deploy ) {
    $schema->deploy;
}
elsif ( $ddl ) {
    $schema->create_ddl_dir(
        [ 'SQLite', 'PostgreSQL'],
        $IWS::VERSION,
        IWS->path_to('ddl')
    );
} else {
    pod2usage(1);
}

1;

=head1 NAME

iws_db.pl - Database Deployment and Management

=head1 SYNOPSIS

iws_db.pl [options]

 Options:
    -? -help    display this help and exit
    -d -deploy  Deploy to the configured database
    -ddl        Create DDL directory and data files

=head1 DESCRIPTION

Setup and deploy to a database or generate the DDL files.

=head1 AUTHOR

J. Shirley C<<< <jshirley@iwatchsoccer.com> >>>

=head1 COPYRIGHT

Copyright J. Shirley, All Rights Reserved

=cut
