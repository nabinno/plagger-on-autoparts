package Plagger::Plugin::Publish::HatenaGraph;
use strict;
use base qw( Plagger::Plugin );

use Encode;
use WebService::Hatena::Graph;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'plugin.init'   => \&initialize,
        'publish.entry' => \&post_to_graph,
    );
}

sub rule_hook { 'publish.entry' }

sub initialize {
    my ($self, $context, $args) = @_;
    $self->{graph} = WebService::Hatena::Graph->new(
        username => $self->conf->{username}, 
        password => $self->conf->{password},
    );
}

sub post_to_graph {
    my ($self, $context, $args) = @_;

    for my $graph (@{$self->conf->{graphs}}) {
        for my $value (@{$args->{entry}->meta->{$graph->{meta_name}}||[]}) {
            if ($graph->{append}) {
                # append: 1なら、現在のグラフの値に加算
                my $data = $self->{graph}->get_data(
                    graphname => encode('utf-8', $graph->{graph_name}), 
                    username  => $self->conf->{username},
                );
                $value += $data->{$args->{entry}->date->ymd} || 0;
            }
            $self->{graph}->post_data(
                graphname => encode('utf-8', $graph->{graph_name}), 
                date      => $args->{entry}->date->ymd, 
                value     => $value,
            );
            $context->log(info => "Post $value to graph '@{[$graph->{graph_name}]}' success. ");
        }
    }
}

1;

__END__

=head1 NAME

Plagger::Plugin::Publish::HatenaGraph - Post to Hatena::Graph automatically

=head1 SYNOPSIS

  - module: Publish::HatenaGraph
    config:
      username: your-username
      password: your-password
      graphs:
        -
          title: today's weight
          name: weight
          pattern: ([0-9.]+)kg

=head1 DESCRIPTION

This plugin automatically posts feed updates to Hatena Graph
L<http://graph.hatena.ne.jp/>. 

=head1 AUTHOR

Kan Fushihara <kan.fushihara at gmail.com>

=head1 SEE ALSO

L<Plagger>, L<WebService::Hatena::Graph>

=cut
