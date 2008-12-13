#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'VirtualBox::Manage' );
}

diag( "Testing VirtualBox::Manage $VirtualBox::Manage::VERSION, Perl $], $^X" );
