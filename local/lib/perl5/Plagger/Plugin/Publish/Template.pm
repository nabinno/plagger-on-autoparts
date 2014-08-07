package Plagger::Plugin::Publish::Template;

use strict;
use warnings;

use Plagger::Util;
use File::Spec;
use Hash::Merge qw( merge );

use base qw( Plagger::Plugin );

sub register {
    my ( $self, $c ) = @_;
    $c->register_hook(
        $self,
        'publish.feed' => $self->can('publish'),
    );
}

sub init {
    my $self = shift;
    $self->SUPER::init( @_ );

    my $dir = $self->conf->{'dir'};
    unless ( -e $dir && -d _ ) {
        mkdir $dir, 0755
            or Plagger->context->error("mkdir $dir: $!");
    }

}

sub publish {
    my ( $self, $c, $args ) = @_;

    my $file = Plagger::Util::filename_for( $args->{'feed'}, $self->conf->{'filename'} || '%i.txt' );
    my $path = File::Spec->catfile( $self->conf->{'dir'}, $file );

    $self->conf->{'variable'}->{'define'}   ||={};
    $self->conf->{'variable'}->{'evaluate'} ||={};

    for my $name ( qw( define evaluate ) ) {
        $c->error( "config->variable->$name is not HASH." )
            if ( ref $self->conf->{'variable'}->{$name} ne 'HASH' );
    }

    my $vars = $self->conf->{'variable'}->{'define'};

    my $evaluate = sub {};
       $evaluate = sub {
        my ( $target ) = @_;
        my $result;

        my $ref = ref $target;
        if ( $ref eq 'HASH' ) {
            $result = {};
            while ( my ( $name, $value ) = each %{ $target } ) {
                $result->{$name} = $evaluate->( $value );
            }
        }
        elsif ( $ref eq 'ARRAY' ) {
            $result = [];
            for my $value ( @{ $target } ) {
                push @{ $result }, $evaluate->( $value );
            }
        }
        else {
            $result = eval $target if ( $target );
            Plagger->context->error( $@ ) if ( $@ );
        }

        return $result;
    };

    my $result = {};

    for my $name ( %{ $self->conf->{'variable'}->{'evaluate'} } ) {
        $result->{$name} = $evaluate->( $self->conf->{'variable'}->{'evaluate'}->{$name} );
    }

    $vars = merge( $vars, $result );

    $vars->{'feed'} = $args->{'feed'};

    my $body = $self->templatize( $self->conf->{'template'} , $vars);

    $c->log(info => "writing output to $path");
    open my $out, ">:utf8", $path or $c->error("$path: $!");
    print $out $body;
    close $out;
}

1;
__END__

=head1 NAME

Plagger::Plugin::Publish::Template -

=head1 SYNOPSIS

  - module: Publish::Template

=head1 DESCRIPTION

XXX Write the description for Publish::Template

=head1 CONFIG

XXX Document configuration variables if any.

=head1 AUTHOR

Naoki Okamura

=head1 SEE ALSO

L<Plagger>

=cut
