# only fetchs 1st entry

sub handle {
    my($self, $args) = @_;
    $args->{entry}->link =~ qr!^http://\w+\.2ch\.net/.*?\d+/!;
}

sub extract {
    my($self, $args) = @_;
    if($args->{entry}->link =~ m!(\d+)$!) {
        my $id = $1;
        $args->{content} =~ s!\s?<br>\s?!\n!g;
        if ($args->{content} =~ m|<dt>(1.*?)<dt>|s){
            my $body = $1;
            return "<div>$body</div>";
        }
    }
    return;
}
