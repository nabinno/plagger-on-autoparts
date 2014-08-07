package Plagger::Plugin::Publish::Diigo;
use strict;
use base qw( Plagger::Plugin );

use Encode;
use Time::HiRes qw(sleep);
use Plagger::Mechanize;
use JSON::Syck;

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
        $mech->agent_alias('Windows Mozilla');
        $mech->quiet(1);
        $self->{mech} = $mech;
    }
    $self->login_diigo;
}


sub add_entry {
    my ($self, $context, $args) = @_;

    my @tags = @{$args->{entry}->tags};
    my $tag_string = @tags ? join(' ', @tags) : '';

    my $summary;
    if ($self->conf->{post_body}) {
        $summary = encode('utf-8', $args->{entry}->body_text); # xxx should be summary
    }

    my $body = JSON::Syck::Dump({
        title       => encode('utf-8', $args->{entry}->title),
        description => $summary || '',
        tags        => $tag_string,
        url         => encode('utf-8', $args->{entry}->link),
        mode        => ($self->conf->{default_public} ? '0' : '2'),
    });

    my $uri = URI->new('http://preview.diigo.com/bookmarklet2');
    $uri->query_form(
        cmd  => 'bm_saveBookmark',
        json => $body,
        v    => 11,
    );
    my $res = eval { $self->{mech}->get($uri->as_string) };
    if (!$res || !$res->is_success) {
        $context->log(info => "can't submit: " . $args->{entry}->link);
    } else {
        $context->log(info => "Post entry success.");
    }
 
    my $sleeping_time = $self->conf->{interval} || 3;
    $context->log(info => "sleep $sleeping_time.");
    sleep( $sleeping_time );
}

sub login_diigo {
    my $self = shift;
    unless ($self->conf->{username} && $self->conf->{password}) {
        Plagger->context->log(error => 'set your username and password before login.');
    }
    my $res = $self->{mech}->get('http://www.diigo.com/sign-in');
    $self->{mech}->submit_form(
        form_name => 'loginForm',
        fields => {
            username => $self->conf->{username},
            password => $self->conf->{password},
        },
    );
    $res && $res->is_success;
}

1;

__END__

=head1 NAME

Plagger::Plugin::Publish::Diigo - Post to diigo bookmark automatically

=head1 SYNOPSIS

  - module: Publish::Diigo
    config:
      username: your-username
      password: your-password
      interval: 2
      post_body: 1
      #default_public: 1

=head1 DESCRIPTION

This plugin automatically posts feed updates to diigo bookmark
L<http://www.diigo.com/>. It supports automatic tagging as well. It
might be handy for synchronizing delicious feeds into diigo bookmark.

=head1 CONFIG

=over 4

=item username, password

username and password for Diigo. Required.

=item default_public

Optional. default publish operation value is '1' as publish.

=item interval

Optional.

=item timeout

Optional.

=back

=head1 AUTHOR

Yasuhiro Matsumoto

=head1 SEE ALSO

L<Plagger>, L<Plagger::Mechanize>

=cut
