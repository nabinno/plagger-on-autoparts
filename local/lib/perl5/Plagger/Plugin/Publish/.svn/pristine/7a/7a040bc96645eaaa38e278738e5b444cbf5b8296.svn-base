package Plagger::Plugin::Publish::Magnolia;
use strict;
use base qw( Plagger::Plugin );

use XML::DOM;
use Encode;
use Time::HiRes qw(sleep);
use Plagger::Mechanize;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'publish.entry' => \&add_entry,
        'publish.init'  => \&initialize,
    );
}

sub initialize {
    my $self = shift;
    unless ($self->{mech}) {
        my $mech = Plagger::Mechanize->new;
        $mech->agent_alias('Windows IE 6');
		$mech->add_header('Accept-Encoding', 'identity');
        $mech->quiet(1);
        $self->{mech} = $mech;
    }
    $self->{apikey} = $self->login_magnolia;
}


sub add_entry {
    my ($self, $context, $args) = @_;

    my @tags = @{$args->{entry}->tags};
    my $tag_string = @tags ? join(',', @tags) : '';

    my $summary;
    if ($self->conf->{post_body}) {
        $summary = encode('utf-8', $args->{entry}->body_text); # xxx should be summary
    }

	my $uri = URI->new('http://ma.gnolia.com/api/rest/1/bookmarks_add');
    $uri->query_form(
        api_key     => $self->{apikey},
        title       => encode('utf-8', $args->{entry}->title),
        description => $summary,
        url         => $args->{entry}->link,
        private     => ($self->conf->{default_private} || 0),
        tags        => encode('utf-8', $tag_string),
        rating      => ($self->conf->{default_rating} || 0),
    );

    my $res = eval { $self->{mech}->get($uri->as_string) };
    if ($res && $res->is_success) {
		my $topNode;
		my $status;
        eval {
            $topNode = XML::DOM::Parser->new->parse( $res->content );
            $status = lc $topNode->getElementsByTagName('response')->[0]->getAttribute('status');
        };
        if ($@) {
            $context->log(info => "can't submit: " . $@);
        } elsif ($status ne 'ok') {
            $context->log(info => "can't submit: " . $status);
        } else {
            $context->log(info => "Post entry success.");
        }
    } else {
       $context->log(error => "fail to bookmark HTTP Status: " . $res->code);
    }
 
    my $sleeping_time = $self->conf->{interval} || 3;
    $context->log(info => "sleep $sleeping_time.");
    sleep( $sleeping_time );
}

sub login_magnolia {
    my $self = shift;
    unless ($self->conf->{username} && $self->conf->{password}) {
        Plagger->context->log(error => 'set your username and password before login.');
    }
	my $uri = URI->new('https://ma.gnolia.com/api/rest/1/get_key');
    $uri->query_form(
        id => $self->conf->{username},
        password => $self->conf->{password},
    );
    my $res = $self->{mech}->get($uri->as_string);
	my $apikey;
	eval {
        my $topNode = XML::DOM::Parser->new->parse( $res->content );
        my $responseNode = $topNode->getElementsByTagName('response')->[0];
        if ("ok" eq lc $responseNode->getAttribute('status')) {
			my $keyNode = $responseNode->getElementsByTagName('key')->[0];
		    $apikey = $keyNode->getChildNodes->[0]->getNodeValue;
        }
    };
	unless($apikey) {
        Plagger->context->log(error => "failed to login to ma.gnolia.");
    }
	$apikey;
}

1;

__END__

=head1 NAME

Plagger::Plugin::Publish::Magnolia - Post to ma.gnolia automatically

=head1 SYNOPSIS

  - module: Publish::Magnolia
    config:
      username: your-username
      password: your-password
      interval: 2
      post_body: 1
      default_private: 0
      default_rating: 3

=head1 DESCRIPTION

This plugin automatically posts feed updates to magnolia
L<http://ma.gnolia.com/>. It supports automatic tagging as well. It
might be handy for synchronizing delicious feeds into ma.gnolia.

=head1 CONFIG

=over 4

=item username, password

username and password for Magnolia. Required.

=item default_private

Optional. default private operation value is 1 as private.

=item default_rating

Optional. default rate value is 0.

=item interval

Optional.

=item timeout

Optional.

=back

=head1 NOTE

ma.gnolia API require api_key, thus you should enable API access at
L<http://ma.gnolia.com/account/advanced/>.

=head1 AUTHOR

Yasuhiro Matsumoto

=head1 SEE ALSO

L<Plagger>, L<Plagger::Plugin::Publish::LivedoorClip>, L<Plagger::Mechanize>

=cut
