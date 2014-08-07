#!/usr/bin/perl
 
use Hello::World;
my $hello = Hello::World->new;
$hello->print;                # prints "Hello, world!\n"
$hello->target("Milky Way");
$hello->print;                # prints "Hello, Milky Way!\n"
 
my $greeting = Hello::World->new(target => "Pittsburgh");
$greeting->print;             # prints "Hello, Pittsburgh!\n"
$hello->print;                # still prints "Hello, Milky Way!\n"