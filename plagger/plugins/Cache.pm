package Plagger::Plugin::Cache;
use strict;
use base qw( Plagger::Plugin );

use DB_File;
use Digest::MD5;

sub register {
    my($self, $context) = @_;
    $context->register_hook(
        $self,
        'update.feed.fixup' => \&update,
        'update.fixup' => \&fixup,
    );

    unless ($self->conf->{file}) {
	$context->error("plase file config");
	return;
    }

    my %cache;
    my $a = tie %cache, 'DB_File', $self->conf->{file};
    $self->{__cache} = \%cache;
}

sub update {
    my($self, $context, $args) = @_;

    return unless $self->{__cache};

    my @entries;
    my $feed = $args->{feed};
    for my $entry ($feed->entries) {
	my $key = $feed->id . '-' . $entry->id_safe;

	$key .= $self->check_key('author', $entry->author);
	$key .= $self->check_key('title', $entry->title);

	my $text = $entry->text;
	utf8::encode($text) if utf8::is_utf8($text);
	my $value = !$self->conf->{diff_mode} || Digest::MD5::md5_hex($text);
	if ($self->{__cache}->{$key}) {
	    next unless $self->conf->{diff_mode};
	    next if $self->{__cache}->{$key} eq $value;
	}
	$self->{__cache}->{$key} = $value;
	push(@entries, $entry);
    }
    $feed->{entries} = \@entries;
}

sub check_key {
    my($self, $flag, $str) = @_;
    utf8::encode($str) if utf8::is_utf8($str);
    return '-' . Digest::MD5::md5_hex($str) if $self->conf->{$flag} && $str;
    return '';
}

sub fixup {
    my($self, $context, $args) = @_;

    return unless $self->{__cache};
    untie %{ $self->{__cache} };

    my $update = $context->update;
    $context->update( Plagger::Update->new );
    for my $feed ($update->feeds) {
	$context->update->add($feed) if @{ $feed->entries };
    }
}

1;

__END__

  - module: Cache
    config:
      file: /home/ko/perl/plagger/cache
      diff_mode: 1
