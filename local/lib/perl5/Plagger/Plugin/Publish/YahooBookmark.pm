package Plagger::Plugin::Publish::YahooBookmark;
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
    $self->login_yahoo_bookmark;
}


sub add_entry {
    my ($self, $context, $args) = @_;

    my @tags = @{$args->{entry}->tags};
    my $tag_string = @tags ? join(',', @tags) : '';

    my $summary;
    if ($self->conf->{post_body}) {
        $summary = encode('utf-8', $args->{entry}->body_text); # xxx should be summary
    }

    my $uri = URI->new('http://bookmarks.yahoo.co.jp/action/bookmark');
    $uri->query_form(
        u => $args->{entry}->link,
        t => encode('utf-8', $args->{entry}->title),
    );

    my $res = eval { $self->{mech}->get($uri->as_string) };
    if ($res && $res->is_success) {
        eval {
            my $folder = 'root';
            my $folder_name = $self->conf->{default_folder};
			# parse folder key from folder name
            if ($folder_name) {
                my $html = $self->{mech}->content;
				utf8::decode($html) unless utf8::is_utf8($html);
                $html =~ s!^.*<select name="newpfid[^>]*>!!isg;
                $html =~ s!</select>.*!!sg;
                $html =~ s!.*<option value=["']([^"']+)["'][^>]*>&nbsp;&nbsp;&nbsp;&nbsp;$folder_name</option>.*!$1!isg;
                $folder = $html if $html =~ /\w\+/;
            }
            $self->{mech}->submit_form(
                form_name => 'form_save',
                fields => {
                    tags       => encode('utf-8', $tag_string),
                    desc       => $summary,
                    newpfid    => $folder,
                    visibility => ($self->conf->{default_public} ? 1 : 0),
                },
                button => 'adminEditAction'
            )
        };
        if ($@) {
            $context->log(info => "can't submit: " . $@);
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

sub login_yahoo_bookmark {
    my $self = shift;
    unless ($self->conf->{username} && $self->conf->{password}) {
        Plagger->context->log(error => 'set your username and password before login.');
    }
    my $res = $self->{mech}->get('http://bookmarks.yahoo.co.jp/all');
    $self->{mech}->submit_form(
        form_name => 'login_form',
        fields => {
            login  => $self->conf->{username},
            passwd => $self->conf->{password},
        },
    );
	if ($self->{mech}->form_name('login_form')) {
        Plagger->context->log(error => "failed to login to yahoo bookmark.");
    }
}

1;

__END__

=head1 NAME

Plagger::Plugin::Publish::YahooBookmark - Post to yahoo bookmark automatically

=head1 SYNOPSIS

  - module: Publish::YahooBookmark
    config:
      username: your-username
      password: your-password
      interval: 2
      post_body: 1
      default_folder: MyFolder
      default_public: 0

=head1 DESCRIPTION

This plugin automatically posts feed updates to yahoo bookmark
L<http://bookmarks.yahoo.co.jp/>. It supports automatic tagging as well. It
might be handy for synchronizing delicious feeds into yahoo bookmark.

=head1 CONFIG

=over 4

=item username, password

username and password for Yahoo Bookmark. Required.

=item default_folder

Optional. default folder name to post, 'root' is default.

=item default_public

Optional. default publish operation value is 0 as publish.

=item interval

Optional.

=item timeout

Optional.

=back

=head1 AUTHOR

Yasuhiro Matsumoto

=head1 SEE ALSO

L<Plagger>, L<Plagger::Plugin::Publish::LivedoorClip>, L<Plagger::Mechanize>

=cut
