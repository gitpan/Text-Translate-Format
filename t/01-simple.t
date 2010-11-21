# vim: filetype=perl :
use strict;
use warnings;

#use Test::More tests => 1; # last test to print
use Test::More 'no_plan';  # substitute with previous line when done

use Text::Translate::Format;

my $ttf = Text::Translate::Format->create('Simple');
isa_ok($ttf, 'Text::Translate::Format', 'Text::Translate::Format::Simple');

$ttf->text(<<END_OF_WHATEVER);
first paragraph

   second paragraph


third paragraph
END_OF_WHATEVER

my $paragraphs = $ttf->paragraphs();
is_deeply($paragraphs,
   [
      'first paragraph',
      '   second paragraph',
      'third paragraph',
   ],
, 'to_paragraphs');

# Regenerate text from paragraphs
$ttf->paragraphs_to_text();
is($ttf->text(), <<END_OF_TEXT, 'to_text');
first paragraph

   second paragraph

third paragraph
END_OF_TEXT
