# vim: filetype=perl :
use strict;
use warnings;

#use Test::More tests => 1; # last test to print
use Test::More 'no_plan';  # substitute with previous line when done

use Text::Translate::Format;

my $ttf = Text::Translate::Format->create('Pod');
isa_ok($ttf, 'Text::Translate::Format', 'Text::Translate::Format::Pod');

$ttf->text(<<END_OF_WHATEVER);


=head1 WHATEVER

Some text here:

   a code example

   that spans multiple paragraphs

=cut

END_OF_WHATEVER

my $paragraphs = $ttf->paragraphs();
is_deeply($paragraphs,
   [
      '=head1 WHATEVER',
      'Some text here:',
      '   a code example

   that spans multiple paragraphs',
      '=cut',
   ],
, 'paragraphs');

# Regenerate text from paragraphs
$ttf->paragraphs_to_text();
is($ttf->text(), <<END_OF_TEXT, 'to_text');
=head1 WHATEVER

Some text here:

   a code example

   that spans multiple paragraphs

=cut
END_OF_TEXT
