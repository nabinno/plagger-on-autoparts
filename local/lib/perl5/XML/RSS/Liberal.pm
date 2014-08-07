# $Id: /mirror/perl/XML-RSS-Liberal/trunk/lib/XML/RSS/Liberal.pm 6074 2007-03-14T09:02:55.421817Z daisuke  $
#
# Copyright (c) 2006-2007 Daisuke Maki <daisuke@endeworks.jp>
# All rights reserved.

package XML::RSS::Liberal;
use strict;
use base qw(XML::RSS::LibXML);
use vars qw($VERSION);
use XML::Liberal;
$VERSION = '0.03';

sub create_libxml
{
    my $self = shift;
    my $p    = XML::Liberal->new('LibXML');
    return $p;
}


1;

__END__

=head1 NAME

XML::RSS::Liberal - XML::RSS With A Liberal Parser

=head1 SYNOPSIS

  use XML::RSS::Liberal;
  my $rss = XML::RSS::Liberal->new;
  $rss->parsefile('rss.xml');

  # See XML::RSS::LibXML for details

=head1 DESCRIPTION

XML::RSS::Liberal is a subclass of XML::RSS::LibXML, for those of you who
want to parse broken RSS files (as they often are). It uses XML::Liberal as
its core parser, and therefore it can parse whatever broken XML you provided,
so as long as XML::Liberal can tolerate it.

=head1 METHODS

=head2 create_libxml

Creates a new parser.

=head1 SEE ALSO

L<XML::RSS::LibXML|XML::RSS::LibXML>
L<XML::Liberal>

=head1 AUTHORS

Daisuke Maki E<lt>daisuke@endeworks.jpE<gt>, Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=cut