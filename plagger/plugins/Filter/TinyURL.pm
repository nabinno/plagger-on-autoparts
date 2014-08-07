package Plagger::Plugin::Filter::TinyURL;
use strict;
use base qw( Plagger::Plugin::Filter::Base );

use URI::Find;
use URI::http;
use WWW::Shorten::TinyURL;

sub filter {
    my($self, $body) = @_;

    local @URI::ttp::ISA = qw(URI::http);

    my $count = 0;
    my $opt = $self->conf->{be} || 'short';
    my $finder = URI::Find->new(sub {
        my ($uri, $orig_uri) = @_;
        if ($opt eq 'long' && $uri =~ /tinyurl/) {
            $count++;
            return makealongerlink($orig_uri);
        } elsif ($opt eq 'short') {
            $count++;
            return makeashorterlink($orig_uri);
        }
    });

    $finder->find(\$body);
    ($count, $body);
}

1;

__END__

=head1 NAME

Plagger::Plugin::Filter::TinyURL - convert URL by TinyURL

=head1 SYNOPSIS

  - module: Filter::TinyURL
    config:
      be: long

=head1 DESCRIPTION

This plugin replaces URL with TinyURL or TinyURL with OriginalURL.

=head1 CONFIG

=over 4

=item text_only

When set to 1, uses HTML::Parser to avoid replacing URL inside
HTML attributes. Defaults to 0.

=item be

When set to long, TinyURL extracted to Original URL.
When set to short, URL converted into TinyURL.

=back

=head1 AUTHOR

Toshi

Tatsuhiko Miyagawa

=head1 SEE ALSO

L<Plagger>, L<HTML::Parser>

=cut