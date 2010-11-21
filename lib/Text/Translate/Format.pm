package Text::Translate::Format;
BEGIN {
  $Text::Translate::Format::VERSION = '0.1.0_01';
}
# ABSTRACT: basic format conversions for Text::Translate

use strict;
use warnings;
use English qw( -no_match_vars );
use Carp;

sub init {
   my $self = shift;
   my %config = ref $_[0] ? %{$_[0]} : @_;

   # clear previous stuff
   %$self = ();

   if (exists $config{text}) {
      croak "no filename if text is provided"
         if exists $config{filename};
      croak "no paragraphs if text is provided"
         if exists $config{paragraphs};
      $self->text($config{text});
   }
   if (exists $config{filename}) {
      croak "no paragraphs if filename is provided"
         if exists $config{paragraphs};
      $self->text_from_file($config{filename});
   }
   if (exists $config{paragraphs}) {
      $self->paragraphs($config{paragraphs});
   }

   return $self;
}

sub new {
   my $package = shift;

   croak "don't call new() on $package, call create() instead"
      if $package eq __PACKAGE__;

   my $self = bless {}, $package;
   $self->init(@_);
   return $self;
}

sub create {
   my $package = shift;
   croak "don't call create() on $package, call new() instead or "
      . "create() on " . __PACKAGE__
      if $package ne __PACKAGE__;
   my $format = shift;
   croak "invalid format '$format'"
      unless $format =~ m{\A \w[\w\d]* \z}mxs;
   my $class = __PACKAGE__ . '::' . $format;
   eval "use $class; 1;"
      or croak "unknown format '$format'";
   my $self = $class->new(@_);
   return $self;
}

#----------- ACCESSORS ------------------------------------------------
sub paragraphs {
   my $self = shift;
   if (@_) {
      $self->{paragraphs} = ref $_[0] ? [ @{$_[0]} ] : @_;
   }
   $self->text_to_paragraphs()
      if (! exists $self->{paragraphs}) && (exists $self->{text});
   return @{$self->{paragraphs}} if wantarray();
   return [@{$self->{paragraphs}}];
}

sub text {
   my $self = shift;
   $self->{text} = shift if @_;
   $self->paragraphs_to_text()
      if (! exists $self->{text}) && (exists $self->{paragraphs});
   return $self->{text};
}


#----------- SETTERS --------------------------------------------------
sub text_from_file {
   my ($self, $filename) = @_;
   my $text;
   local $/;
   if (ref $filename) {
      $text = <$filename>;
   }
   else {
      open my $fh, '<', $filename or croak "open('$filename'): $OS_ERROR";
      my $text = <$fh>;
      close $fh;
   }
   return $self->text($text);
}


#----------- TRANSFORMERS ---------------------------------------------
sub paragraphs_to_text { croak "paragraphs_to_text is not implemented" }
sub text_to_paragraphs { croak "text_to_paragraphs is not implemented" }

1;


=pod

=head1 NAME

Text::Translate::Format - basic format conversions for Text::Translate

=head1 VERSION

version 0.1.0_01

=head1 SYNOPSIS

   my $obj = Text::Translate::Format->new(
      Pod => filename => '/opt/perl-5.12.2/lib/5.12.2/pod/perlfunc.pod'
   );

   my @paragraphs = $obj->paragraphs();

   my @translated = translate(@paragraphs);
   my $trans_obj = Text::Translate::Format->new(
      Pod => paragraphs => \@translated
   );
   print "Translated POD:\n", $trans_obj->text();

=head1 DESCRIPTION

This module allows transforming a text into paragraphs (suitable for
handling through <L/Text::Translate>) and vice-versa. This module
is actually a base class for format-specific subclasses, and acts as
a factory to generate objects of these subclasses as well.

The typical life cycle will be the following:

=over

=item *

load the source text from a file (or from a filehandle, or directly
from a scalar variable):

   my $src = Text::Translate::Format->new(
      Pod => filename => '/path/to/file.pod'
   );

=item *

get the paragraphs:

   my @src_paragraphs = $src->paragraphs();

=item *

translate the paragraphs:

   my @dst_paragraphs = translate(@src_paragraphs);

=item *

create an object for the translated document:

   my $dst = Text::Translate::Format->new(
      Pod => paragraphs => \@dst_paragraphs
   );

=item *

get the textual rendition, e.g. for saving it or displaying:

   my $translated = $dst->text();
   print "Translated text:\n", $translated;

=back

=head1 METHODS

=head2 init

   $obj->init(%args);

Object method.

(re)-initialise the object. You can pass one (and only one) of the
following parameters in the C<%args>:

=over

=item C<text>

the text to be converted into paragraphs;

=item C<filename>

the name of a file containing the text to convert into paragraphs;

=item C<paragraphs>

an array reference to the ordered list of paragraphs.

=back

You can pass a reference to a hash instead of a hash.

Returns the input C<$obj>.

=head2 new

   Text::Translate::Format::Whatever->new(%args);

Class method, to be called on derived classes (croaks when called on
L<Text::Translate::Format>).

Accepts the same arguments as L</init>.

Returns a reference to the new object.

=head2 create

   Text::Translate::Format->create($format => %args)

Class method, to be called on the L<Text::Translate::Format> class (by
default, croaks when called in derived classes).

This is a factory method to generate an object of the right C<$format>.

Apart from the first parameter - that represents the format - all the
following parameters are the same as L</init>.

Returns a reference to the newly created object.

=head2 paragraphs

   # setter
   $obj->paragraphs(@paragraphs);
   $obj->paragraphs(\@pars);

   # getter
   my @paragraphs  = $obj->paragraphs();
   my $ref_to_pars = $obj->paragraphs();

Object method, can be used as both a setter and a getter.

This method allows setting or getting the list of paragraphs.

If there are input parameters, they are set as the paragraphs list. It can
be either a straight list, or a reference to an array containing the list.

Always returns the current list of paragraphs (in the setter case, returns
the newly set list) in list context, a reference to an anonymous array
containing the list in scalar context.

=head2 text

   # setter
   $obj->text($text);

   # getter
   my $text = $obj->text();

Object method, can be used as both a setter and a getter.

This method allows setting or getting a text rendition of the paragraphs.

If there is an input parameter, it is considered as the text to be set.

Always returns the current text (i.e. the newly set text in case of the
setter).

=head2 text_from_file

   # Can pass either a filename or an open filehandle to read from
   my $text = $obj->text_from_file($filename);
   my $text = $obj->text_from_file($FILEHANDLE);

Object method.

This method allows setting the text rendition of the paragraphs, reading
it from either a file (provided through its filename) or from a filehandle.

Accepts either a filehandle or a filename.

Returns the text read from the file and set as L</text>.

=head2 paragraphs_to_text

   $obj->paragraphs_to_text();

Object method.

This method MUST be overridden in the derived classes; it takes the
list of paragraphs (via L</paragraphs>) and generate the textual rendition
(setting it through L</text>).

=head2 text_to_paragraphs

   $obj->text_to_paragraphs();

Object method.

This method MUST be overridden in the derived classes; it takes the
textual representation (via L</text>) and generates the list of
paragraphs (setting it through L</paragraphs>).

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

