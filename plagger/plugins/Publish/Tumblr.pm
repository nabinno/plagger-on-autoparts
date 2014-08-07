package Plagger::Plugin::Publish::Tumblr;
use strict;
use base qw( Plagger::Plugin );

use WWW::Tumblr;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'publish.entry' => \&publish_entry,
        'plugin.init'   => \&initialize,
    );
}

sub initialize {
    my($self, $context) = @_;

    $self->{tumblr} = WWW::Tumblr->new;
    $self->{tumblr}->email($self->conf->{username});
    $self->{tumblr}->password($self->conf->{password});
}

sub tumblr_param {
    my($e) = @_;

    my $parameter_tmpl = {
        regular => {
            title       => $e->title,
            body        => $e->{body}->data,
        }, 
        link => {
#            name        => $e->title,
            url         => $e->link,
            description => $e->{body}->data,
        }, 
        quote => {
            source      => qq{<a href="$e->link">$e->title</a>},
            quote       => $e->{body}->data,
        }, 
    };

    return $parameter_tmpl;
}

sub publish_entry {
    my($self, $context, $args) = @_;

    my $param = tumblr_param($args->{entry});
    my $type = 'link' || $self->conf->{type};
#    my $param = $self->templatize('tumblr.tt', $args);

    my $is_success = $self->{tumblr}->write(
        type => $type,
        %{$param->{$type}}, 
    );
    if ($is_success) {
        $context->log(info => "Post to Tumblr '$type' to '$e->{body}'");
    } else {
        $context->log(error => "$self->{tumblr}->errstr()");
    }

}

1;
__END__

=head1 NAME

Plagger::Plugin::Publish::Tumblr - Post to tumblr.com

=head1 SYNOPSIS

  - module: Publish::Tumblr
    config:
      username: your-tumblrs-emailaddress
      password: your-password
      type: link

=head1 DESCRIPTION

Post tumblr.com

=head1 CONFIG

=over4

=item username, password

Your login account in tumblr.com

=item type

select 'regular, quote, link'
(not implemented 'conversation, photo, video, audio')

=back

=cut

=head1 AUTHOR

Masafumi Otsune

=head1 SEE ALSO

L<Plagger>, L<WWW::Tumblr>, L<http://www.tumblr.com/api>

=cut
