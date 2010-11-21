package Text::Translate::Format::Pod;
BEGIN {
  $Text::Translate::Format::Pod::VERSION = '0.1.0_01';
}
# ABSTRACT: POD handler for Text::Translate::Format

use strict;
use warnings;
use Carp;
use English qw( -no_match_vars );

use base 'Text::Translate::Format';

# Module implementation here
sub text_to_paragraphs {
   my ($self) = @_;
   (my $text = $self->text()) =~ s/\A\n+|\n+\z//mxs;

   my (@buffer, @paragraphs);
   my @candidates = split /\n\s*\n/, $text;
   for my $candidate (@candidates) {
      if ($candidate =~ /\A\s/mxs) {
         push @buffer, $candidate;
         next;
      }
      if (@buffer) {
         push @paragraphs, join "\n\n", @buffer;
         @buffer = ();
      }
      push @paragraphs, $candidate;
   }
   push @paragraphs, join "\n\n", @buffer if @buffer;

   $self->paragraphs(\@paragraphs);
   return $self;
}

sub paragraphs_to_text {
   my ($self) = @_;
   $self->text(join("\n\n", $self->paragraphs()) . "\n");
   return $self;
}

1;


=pod

=head1 NAME

Text::Translate::Format::Pod - POD handler for Text::Translate::Format

=head1 VERSION

version 0.1.0_01

=head1 DESCRIPTION

This module fits into the L<Text::Translate::Format> system for handling
conversion between POD documents and paragraphs (suitable for translating
via L<Text::Translate>) and vice-versa.

=head1 METHODS

=head2 text_to_paragraphs

Overridden method from L<Text::Translate::Format>.

=head2 paragraphs_to_text

Overridden method from L<Text::Translate::Format>.

=head1 AUTHOR

Flavio Poletti <polettix@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Flavio Poletti.

This module is free software.  You can redistribute it and/or
modify it under the terms of the Artistic License 2.0.

This program is distributed in the hope that it will be useful,
but without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut


__END__

