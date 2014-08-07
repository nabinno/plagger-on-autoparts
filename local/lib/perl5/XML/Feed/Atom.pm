# $Id: Atom.pm 1958 2006-08-14 05:31:27Z btrott $

package XML::Feed::Atom;
use strict;

use base qw( XML::Feed );
use XML::Atom::Feed;
use XML::Atom::Util qw( iso2dt );
use List::Util qw( first );
use DateTime::Format::W3CDTF;

use XML::Atom::Entry;
XML::Atom::Entry->mk_elem_accessors(qw( lat long ), ['http://www.w3.org/2003/01/geo/wgs84_pos#']);

use XML::Atom::Content;

sub init_empty {
    my ($feed, %args) = @_;
    $args{'Version'} ||= '1.0';
    
    $feed->{atom} = XML::Atom::Feed->new(%args);
    $feed;
}

# monkey patch
{
    my $sub =  sub {
        my $item = shift;
        if (XML::Atom::LIBXML) {
            my $elem = $item->elem;
            if (@_) {
                $elem->setAttributeNS('http://www.w3.org/XML/1998/namespace',
                    'base', $_[0]);
            }
            return $elem->getAttributeNS('http://www.w3.org/XML/1998/namespace', 'base');
        } else {
            if (@_) {
                $item->elem->setAttribute('xml:base', $_[0]);
            }
            return $item->elem->getAttribute('xml:base');
        }

    };
    no strict 'refs';
    *XML::Atom::Feed::base    = $sub unless XML::Atom::Feed->can('base');
    *XML::Atom::Entry::base   = $sub unless XML::Atom::Entry->can('base');
    *XML::Atom::Content::base = $sub unless XML::Atom::Content->can('base');
}

sub init_string {
    my $feed = shift;
    my($str) = @_;
    if ($str) {
        $feed->{atom} = XML::Atom::Feed->new(Stream => $str)
            or return $feed->error(XML::Atom::Feed->errstr);
    }
    $feed;
}

sub format { 'Atom' }

sub title { shift->{atom}->title(@_) }
sub link {
    my $feed = shift;
    if (@_) {
        $feed->{atom}->add_link({ rel => 'alternate', href => $_[0],
                                  type => 'text/html', });
    } else {
        my $l = first { !defined $_->rel || $_->rel eq 'alternate' } $feed->{atom}->link;
        $l ? $l->href : undef;
    }
}

sub self_link {
    my $feed = shift;
    if (@_) {
        my $uri = shift;
        $feed->{atom}->add_link({type => "application/atom+xml", rel => "self", href => $uri});
        return $uri;
    } 
    else
    {
        my $l =
            first
            { !defined $_->rel || $_->rel eq 'self' }
            $feed->{atom}->link;
            ;

        return $l ? $l->href : undef;
    }
}

sub description { shift->{atom}->tagline(@_) }
sub copyright   { shift->{atom}->copyright(@_) }
sub language    { shift->{atom}->language(@_) }
sub generator   { shift->{atom}->generator(@_) }
sub id          { shift->{atom}->id(@_) }
sub updated     { shift->{atom}->updated(@_) }
sub add_link    { shift->{atom}->add_link(@_) }
sub base        { shift->{atom}->base(@_) }

sub author {
    my $feed = shift;
    if (@_ && $_[0]) {
        my $person = XML::Atom::Person->new(Version => 1.0);
        $person->name($_[0]);
        $feed->{atom}->author($person);
    } else {
        $feed->{atom}->author ? $feed->{atom}->author->name : undef;
    }
}




sub modified {
    my $feed = shift;
    if (@_) {
        $feed->{atom}->modified(DateTime::Format::W3CDTF->format_datetime($_[0]));
    } else {
        return iso2dt($feed->{atom}->modified) if $feed->{atom}->modified;
        return iso2dt($feed->{atom}->updated)  if $feed->{atom}->updated;
        return undef;
    }
}

sub entries {
    my @entries;
    for my $entry ($_[0]->{atom}->entries) {
        push @entries, XML::Feed::Entry::Atom->wrap($entry);
    }

    @entries;
}

sub add_entry {
    my $feed  = shift;
    my $entry = shift || return;
    $entry    = $feed->_convert_entry($entry);
    $feed->{atom}->add_entry($entry->unwrap);
}

sub as_xml { $_[0]->{atom}->as_xml }

package XML::Feed::Entry::Atom;
use strict;

use base qw( XML::Feed::Entry );
use XML::Atom::Util qw( iso2dt );
use XML::Feed::Content;
use XML::Atom::Entry;
use List::Util qw( first );

sub init_empty {
    my $entry = shift;
    $entry->{entry} = XML::Atom::Entry->new(Version => 1.0);
    1;
}

sub title { shift->{entry}->title(@_) }
sub source { shift->{entry}->source(@_) }
sub updated { shift->{entry}->updated(@_) }
sub base { shift->{entry}->base(@_) }

sub link {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->add_link({ rel => 'alternate', href => $_[0],
                                    type => 'text/html', });
    } else {
        my $l = first { !defined $_->rel || $_->rel eq 'alternate' } $entry->{entry}->link;
        $l ? $l->href : undef;
    }
}

sub summary {
    my $entry = shift;
    if (@_) {
		my %param;
		if (ref($_[0]) eq 'XML::Feed::Content') {
			%param = (Body => $_[0]->body);
		} else {
			 %param = (Body => $_[0]);
		}
		$entry->{entry}->summary(XML::Atom::Content->new(%param, Version => 1.0));
    } else {
		my $s = $entry->{entry}->summary;
        # map Atom types to MIME types
        my $type = ($s && ref($s) eq 'XML::Feed::Content') ? $s->type : undef;
        if ($type) {
            $type = 'text/html'  if $type eq 'xhtml' || $type eq 'html';
            $type = 'text/plain' if $type eq 'text';
        }
		my $body = $s;	
		if (defined $s && ref($s) eq 'XML::Feed::Content') {
			$body = $s->body;
		}
        XML::Feed::Content->wrap({ type => $type,
                                   body => $body });
    }
}

my %types = (
	'text/xhtml' => 'xhtml',
	'text/html'  => 'html',
	'text/plain' => 'text',
);

sub content {
    my $entry = shift;
    if (@_) {
        my %param;
        my $base;
        if (ref($_[0]) eq 'XML::Feed::Content') {
			if (defined $_[0]->type && defined $types{$_[0]->type}) {
	            %param = (Body => $_[0]->body, Type => $types{$_[0]->type});
			} else {
	            %param = (Body => $_[0]->body);
			}
            $base = $_[0]->base if defined $_[0]->base;
        } else {
            %param = (Body => $_[0]);
        }
        $entry->{entry}->content(XML::Atom::Content->new(%param, Version => 1.0));
        $entry->{entry}->content->base($base) if defined $base;
    } else {
        my $c = $entry->{entry}->content;

        # map Atom types to MIME types
        my $type = $c ? $c->type : undef;
        if ($type) {
            $type = 'text/html'  if $type eq 'xhtml' || $type eq 'html';
            $type = 'text/plain' if $type eq 'text';
        }

        XML::Feed::Content->wrap({ type => $type,
                                   base => $c ? $c->base : undef, 
                                   body => $c ? $c->body : undef });
    }
}

sub category {
    my $entry = shift;
    my $ns = XML::Atom::Namespace->new(dc => 'http://purl.org/dc/elements/1.1/');
    if (@_) {
        $entry->{entry}->add_category({ term => $_[0] });
    } else {
        my $category = $entry->{entry}->category;
        my @return = $category ? ($category->label || $category->term) : $entry->{entry}->getlist($ns, 'subject');
        return wantarray? @return : $return[0];
    }
}

sub author {
    my $entry = shift;
    if (@_ && $_[0]) {
        my $person = XML::Atom::Person->new(Version => 1.0);
        $person->name($_[0]);
        $entry->{entry}->author($person);
    } else {
        $entry->{entry}->author ? $entry->{entry}->author->name : undef;
    }
}

sub id { shift->{entry}->id(@_) }

sub issued {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->issued(DateTime::Format::W3CDTF->format_datetime($_[0])) if $_[0];
    } else {
        $entry->{entry}->issued ? iso2dt($entry->{entry}->issued) : undef;
    }
}

sub modified {
    my $entry = shift;
    if (@_) {
        $entry->{entry}->modified(DateTime::Format::W3CDTF->format_datetime($_[0])) if $_[0];
    } else {
        return iso2dt($entry->{entry}->modified) if $entry->{entry}->modified;
        return iso2dt($entry->{entry}->updated)  if $entry->{entry}->updated;
        return undef;
    }
}

sub lat {
    my $entry = shift;
    if (@_) {
   $entry->{entry}->lat($_[0]) if $_[0];
    } else {
   $entry->{entry}->lat;
    }
}

sub long {
    my $entry = shift;
    if (@_) {
   $entry->{entry}->long($_[0]) if $_[0];
    } else {
   $entry->{entry}->long;
    }
}

1;
