package XML::Liberal::Remedy::LowAsciiChars;
use strict;
use base qw( XML::Liberal::Remedy );

# optimized to fix all errors in one apply() call
sub apply {
    my $self = shift;
    my($xml_ref) = @_;
    my $match = $$xml_ref =~ s{&#(?:(\d+)|x([0-9A-Fa-f]{2,4}));}{
        ($1 && is_low_ascii($1)) || ($2 && is_low_ascii(hex($2)))
            ? '' : $&;
    }eg;
    return 1 if $match;

    Carp::carp("Can't find low ascii bytes $self->{error}");
    return;
}

my %is_low_ascii = map { $_ => 1 } (0..8, 11..12, 14..31, 127);

sub is_low_ascii {
    my $num = shift;
    $is_low_ascii{$num};
}

1;
