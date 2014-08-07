#
# $Id: MSN.pm 3 2007-01-06 08:39:31Z hironori.yoshida $
#
package Plagger::Plugin::Publish::MSN;
use strict;
use warnings;
use base qw(Plagger::Plugin);

use Encode;
use Net::MSN;

our $VERSION = 0.01;

# patch for Net::MSN
BEGIN {
    my $process_event = Net::MSN->can('process_event');
    undef *Net::MSN::process_event;
    *Net::MSN::process_event = sub {
        my ( $self, $this_self, $line, $fh ) = @_;
        print {*STDERR} ( substr $line, 0, 60 ) . "\n";

        my ( $cmd, @data ) = split /\s/msx, $line;

        if ( !$cmd ) {
            return;
        }

        if ( $cmd eq 'LST' ) {
            $self->buddyupdate( $data[0], $data[1], 'NLN' );
            return 1;
        }
        elsif ( $cmd eq 'QNG' ) {
            if ( $self->if_callback_exists('_on_QNG') ) {
                &{ $self->{Callback}->{_on_QNG} };
            }
        }
        goto &{$process_event};
    };
    return;
}

sub register {
    my ( $self, $context ) = @_;
    $context->register_hook(
        $self,
        'publish.entry'    => \&entry,
        'publish.finalize' => \&finalize,
    );
    return;
}

my @messages;

sub entry {
    my ( $self, $context, $args ) = @_;
    my $entry = $args->{entry};
    use Plagger::Util;
    my $message = (
        join "\n",
        $entry->permalink
          . ( $entry->author ? ' posted by ' . $entry->author : q{} ),
        $entry->title_text                           || q{},
        Plagger::Util::strip_html( $entry->summary ) || q{},
    );
    push @messages, $message;
    return;
}

sub finalize {
    my ($self) = @_;

    if ( !@messages ) {
        return;
    }

    my $is_alive = 1;
    my $is_join  = 0;

    local $SIG{INT} = local $SIG{HUP} = local $SIG{QUIT} = local $SIG{TERM} =
      sub { $is_alive = 0 };
    my $msn = Net::MSN->new;
    $msn->set_event(
        _on_QNG => sub {
            if ( $msn->is_buddy_online( $self->conf->{email} ) ) {
                $msn->call( $self->conf->{email} );
            }
            else {
                $is_alive = 0;
            }
        },
        on_message => sub {
            my ( $sb, $chandle, $friendly, $message ) = @_;
            if ( $message =~ /^(quit|exit|die|bye)$/imsx ) {
                $is_alive = 0;
            }
        },
        on_join => sub {
            $is_join = 1;
        },
        on_bye => sub {
            $is_alive = 0;
        },
    );
    $msn->connect( $self->conf->{bot}->{email}, $self->conf->{bot}->{password} )
      or $is_alive = 0;

    my $timeout  = $self->conf->{bot}->{timeout}  || 60;
    my $interval = $self->conf->{bot}->{interval} || 3;

    my $t = time;
    while (1) {
        last if !$is_alive;
        last if !@messages;
        if ( !$is_join ) {
            last if $timeout < time - $t;    # timeout
        }
        else {
            my $message = shift @messages;
            my $t2      = time;
            $msn->sendmsg( $self->conf->{email}, encode( 'utf8', $message ) );

            # interval loop
            while ( time - $t2 <= $interval ) {
                $msn->check_event;
            }
        }
        $msn->check_event;
    }
    $msn->disconnect;
    return;
}

1;

__END__

=head1 NAME

Plagger::Plugin::Publish::MSN - Publish feeds to Windows/MSN/Live Messenger

=head1 VERSION

This document describes Plagger::Plugin::Publish::MSN 0.01

=head1 SYNOPSIS

    use Plagger::Plugin::Publish::MSN;
    - module: Publish::MSN
      config:
        email: your_hotmail@example.com
        bot:
          email: bot_hotmail@example.com
          password: bot_password
          timeout: 60
          interval: 3

=head1 DESCRIPTION

It publish feeds to Windows/MSN/Live Messenger if you are online.

=head1 SUBROUTINES/METHODS

=head2 register( $context )

=head2 entry( $context, \%args )

=head2 finalize( )

=head1 DIAGNOSTICS

None.

=head1 CONFIGURATION AND ENVIRONMENT

=head2 email (REQUIRED)

It is your account.

=head2 bot (REQUIRED)

=head3 email (REQUIRED)

It is an account of bot.

=head3 password (REQUIRED)

It is a password of bot.

=head3 timeout (OPTIONAL)

It is a timeout of bot.
Default is 60 sec.

=head3 interval (OPTIONAL)

It is an interval of each message.
Default is 3 sec.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
L<http://code.google.com/p/nolugger>.

=head2 Net::MSN has a problem.

Net::MSN seems not to support LiveMessenger.

The message which is NLN or ILN does not appear.

=head2 No message format support.

=head2 The bot login many times.

=head1 AUTHOR

Hironori Yoshida C<< <yoshida@cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2006, Hironori Yoshida C<< <yoshida@cpan.org> >>. All rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself. See L<perlartistic>.

=cut
