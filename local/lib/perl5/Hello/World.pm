# In Perl there is no special 'class' definition.  A namespace is a class.
package Hello::World;
 
use strict;
use warnings;
 
our $VERSION = "1.00";
 
=head1 NAME
 
Hello::World - An encapsulation of a common output message
 
=head1 SYNOPSIS
 
    use Hello::World;
    my $hello = Hello::World->new();
    $hello->print;
 
=head1 DESCRIPTION
 
This is an object-oriented library which can print the famous "H.W."
message.
 
=head2 Methods
 
=head3 new
 
    my $hello = Hello::World->new();
    my $hello = Hello::World->new( target => $target );
 
Instantiates an object which holds a greeting message.  If a C<$target> is
given it is passed to C<< $hello->target >>.
 
=cut
 
# The constructor of an object is called new() by convention.  Any
# method may construct an object and you can have as many as you like.
 
sub new {
 my($class, %args) = @_;
 
 my $self = bless({}, $class);
 
 my $target = exists $args{target} ? $args{target} : "world";
 $self->{target} = $target;
 
 return $self;
}
 
 
=head3 target
 
    my $target = $hello->target;
    $hello->target($target);
 
Gets and sets the current target of our message.
 
=cut
 
sub target {
  my $self = shift;
  if( @_ ) {
      my $target = shift;
      $self->{target} = $target;
  }
 
  return $self->{target};
}
 
 
=head3 to_string
 
    my $greeting = $hello->to_string;
 
Returns the $greeting as a string
 
=cut
 
sub to_string {
 my $self = shift;
 return "Hello, $self->{target}!";
}
 
 
=head3 print
 
    $hello->print;
 
Outputs the greeting to STDOUT
 
=cut
 
sub print {
 my $self = shift;
 print $self->to_string(), "\n";
}
 
=head1 AUTHOR
 
Joe Hacker <joe@joehacker.org>
 
=cut
 
1;