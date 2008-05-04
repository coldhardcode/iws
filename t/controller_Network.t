use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'IWS' }
BEGIN { use_ok 'IWS::Controller::Network' }

ok( request('/network')->is_success, 'Request should succeed' );


