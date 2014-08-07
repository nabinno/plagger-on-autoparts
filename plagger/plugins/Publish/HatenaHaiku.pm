package Plagger::Plugin::Publish::HatenaHaiku;
use strict;
use base qw( Plagger::Plugin );

use Encode;
use Time::HiRes qw(sleep);
use URI;
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
        $mech->quiet(1);
        $self->{mech} = $mech;
    }
    $self->login_hatena_haiku;
}


sub add_entry {
    my ($self, $context, $args) = @_;

    unless ($self->conf->{default_keyword}) {
        Plagger->context->log(error => 'set default_keyword.');
    }
    my $summary = encode('utf-8', $args->{entry}->title)
        . "\n" . encode('utf-8', $args->{entry}->link);
    my $keyword = $self->conf->{default_keyword};

    my $keyword_behaviour = $self->conf->{keyword_behaviour};
    if ('default' ne $keyword_behaviour) {
        if ('tag' eq $keyword_behaviour) {
            my @tags = @{$args->{entry}->tags};
            $keyword = $tags[0] if ($tags[0]);
        }
        if ('title' eq $keyword_behaviour) {
            if ($summary =~ /^\[([^\]]+)\]/) {
                $keyword = $1;
            }
        }
    }

    my $res = eval { $self->{mech}->get('http://h.hatena.ne.jp/') };
    if ($res && $res->is_success) {
        eval {
            $self->{mech}->submit_form(
                form_number => 1,
                fields => {
                    word       => encode('utf-8', $keyword),
                    body       => $summary,
                },
            )
        };
        if ($@) {
            $context->log(info => "can't submit: " . $@);
        } else {
            $context->log(info => "Post entry success.");
        }
    } else {
       $context->log(error => "fail to post HTTP Status: " . $res->code);
    }
 
    my $sleeping_time = $self->conf->{interval} || 3;
    $context->log(info => "sleep $sleeping_time.");
    sleep( $sleeping_time );
}

sub login_hatena_haiku {
    my $self = shift;
    unless ($self->conf->{username} && $self->conf->{password}) {
        Plagger->context->log(error => 'set your username and password before login.');
    }
    my $res = $self->{mech}->get('https://www.hatena.ne.jp/login?location=http://h.hatena.ne.jp/');
    $self->{mech}->submit_form(
        form_number => 1,
        fields => {
            name  => $self->conf->{username},
            password => $self->conf->{password},
        },
    );
    if ($self->{mech}->content !~ 'http-equiv="Refresh"') {
        Plagger->context->log(error => "failed to login to hatena haiku.");
    }
}

1;

__END__

=head1 NAME

Plagger::Plugin::Publish::HatenaHaiku - Post to hatena haiku automatically

=head1 SYNOPSIS

  - module: Publish::HatenaHaiku
    config:
      username: your-username
      password: your-password
      default_keyword: id:mattn
      #keyword_behaviour: title
      #keyword_behaviour: tag
      #interval: 2

=head1 DESCRIPTION

This plugin automatically posts feed updates to hatena haiku
L<http://h.hatena.ne.jp/>. It supports automatic tagging(keyword) as well.
It might be handy for synchronizing your blog feeds into hatena haiku.

=head1 CONFIG

=over 4

=item username, password

username and password for Hatena Haiku. Required.

=item default_keyword

default keyword string. Required.

=item keyword_behaviour

Optional. if set 'title', it should accept 'plagger' in '[plagger]title'.
if set 'tag', it should accept a first of tags in feed.

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
