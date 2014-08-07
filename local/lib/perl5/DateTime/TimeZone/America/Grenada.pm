# This file is auto-generated by the Perl DateTime Suite time zone
# code generator (0.07) This code generator comes with the
# DateTime::TimeZone module distribution in the tools/ directory

#
# Generated from /tmp/PHvstgqvGl/northamerica.  Olson data version 2012e
#
# Do not edit this file directly.
#
package DateTime::TimeZone::America::Grenada;
{
  $DateTime::TimeZone::America::Grenada::VERSION = '1.48';
}

use strict;

use Class::Singleton 1.03;
use DateTime::TimeZone;
use DateTime::TimeZone::OlsonDB;

@DateTime::TimeZone::America::Grenada::ISA = ( 'Class::Singleton', 'DateTime::TimeZone' );

my $spans =
[
    [
DateTime::TimeZone::NEG_INFINITY,
60289416420,
DateTime::TimeZone::NEG_INFINITY,
60289401600,
-14820,
0,
'LMT'
    ],
    [
60289416420,
DateTime::TimeZone::INFINITY,
60289402020,
DateTime::TimeZone::INFINITY,
-14400,
0,
'AST'
    ],
];

sub olson_version { '2012e' }

sub has_dst_changes { 0 }

sub _max_year { 2022 }

sub _new_instance
{
    return shift->_init( @_, spans => $spans );
}



1;
