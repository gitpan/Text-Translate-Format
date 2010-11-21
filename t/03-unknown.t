# vim: filetype=perl :
use strict;
use warnings;

#use Test::More tests => 1; # last test to print
use Test::More 'no_plan';  # substitute with previous line when done

use Text::Translate::Format;

my $ttf = eval { Text::Translate::Format->create('WhateVer') };
my $error = $@;
ok(!$ttf, 'WhateVer format did not succeed');
like($error, qr/unknown format/, 'error message');
