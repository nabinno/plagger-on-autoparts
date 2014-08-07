package Plagger::Plugin::Publish::XSLT;

use strict;
use base qw( Plagger::Plugin::Publish::Feed );

use XML::LibXML;
use XML::LibXSLT;
use File::Spec;

our $stylesheet;

sub register {
	my ($self, $context) = @_;

	$self->SUPER::register($context);

	$context->register_hook(
		$self,
		'publish.feed' => \&publish_feed,
		'plugin.init'  => \&plugin_init,
	);
}

sub plugin_init {
	my ($self, $context, $args) = @_;

	my $xslt   = XML::LibXSLT->new();
	$context->log(debug => "loading " . $self->conf->{xsl} . " as StyleSheet");
	$stylesheet = $xslt->parse_stylesheet_file($self->conf->{xsl});
}

sub publish_feed {
	my ($self, $context, $args) = @_;

	$context->log(info => "XSLT processing Start..");
	my $f = $args->{feed};
	my $filepath = File::Spec->catfile($self->conf->{dir}, $self->gen_filename($f));

	my $parser = XML::LibXML->new();

	$context->log(debug => "loading $filepath as source XML");
	my $source = $parser->parse_file($filepath);

	my $result = $stylesheet->output_string( 
		$stylesheet->transform($source)
	);
	
	my $ext = $self->conf->{extension};
	$filepath =~ s/\..+?$/.$ext/;
	$context->log(info => "save feed for " . $f->link . " to $filepath");

	utf8::decode($result) unless utf8::is_utf8($result);
	open my $output, ">:utf8", $filepath or $context->error("$filepath: $!");
	print $output $result;
	close $output;
}


1;
__END__

=head1 NAME

Plagger::Plugin::Publish::XSLT - Publish with translating by XSLT

=head1 SYNOPSIS

  - module: Publish::XSLT
    config:
      format: Atom
      dir: /path/to/output/dir
      xsl: /path/to/xslt/file
      extension: html


=head1 DESCRIPTION

This plugin publish translated feeds by XSLT.

=head1 AUTHOR

cho45 <cho45@lowreal.net>, http://lowreal.net/

=head1 SEE ALSO

L<Plagger>

=cut
