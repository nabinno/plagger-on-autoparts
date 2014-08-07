# This file is auto-generated by the Perl DateTime Suite time zone
# code generator (0.07) This code generator comes with the
# DateTime::TimeZone module distribution in the tools/ directory

#
# Generated from /tmp/PHvstgqvGl/europe.  Olson data version 2012e
#
# Do not edit this file directly.
#
package DateTime::TimeZone::Asia::Sakhalin;
{
  $DateTime::TimeZone::Asia::Sakhalin::VERSION = '1.48';
}

use strict;

use Class::Singleton 1.03;
use DateTime::TimeZone;
use DateTime::TimeZone::OlsonDB;

@DateTime::TimeZone::Asia::Sakhalin::ISA = ( 'Class::Singleton', 'DateTime::TimeZone' );

my $spans =
[
    [
DateTime::TimeZone::NEG_INFINITY,
60104644152,
DateTime::TimeZone::NEG_INFINITY,
60104678400,
34248,
0,
'LMT'
    ],
    [
60104644152,
61125807600,
60104676552,
61125840000,
32400,
0,
'CJT'
    ],
    [
61125807600,
61367122800,
61125840000,
61367155200,
32400,
0,
'JST'
    ],
    [
61367122800,
62490574800,
61367162400,
62490614400,
39600,
0,
'SAKT'
    ],
    [
62490574800,
62506382400,
62490618000,
62506425600,
43200,
1,
'SAKST'
    ],
    [
62506382400,
62522110800,
62506422000,
62522150400,
39600,
0,
'SAKT'
    ],
    [
62522110800,
62537918400,
62522154000,
62537961600,
43200,
1,
'SAKST'
    ],
    [
62537918400,
62553646800,
62537958000,
62553686400,
39600,
0,
'SAKT'
    ],
    [
62553646800,
62569454400,
62553690000,
62569497600,
43200,
1,
'SAKST'
    ],
    [
62569454400,
62585269200,
62569494000,
62585308800,
39600,
0,
'SAKT'
    ],
    [
62585269200,
62601001200,
62585312400,
62601044400,
43200,
1,
'SAKST'
    ],
    [
62601001200,
62616726000,
62601040800,
62616765600,
39600,
0,
'SAKT'
    ],
    [
62616726000,
62632450800,
62616769200,
62632494000,
43200,
1,
'SAKST'
    ],
    [
62632450800,
62648175600,
62632490400,
62648215200,
39600,
0,
'SAKT'
    ],
    [
62648175600,
62663900400,
62648218800,
62663943600,
43200,
1,
'SAKST'
    ],
    [
62663900400,
62679625200,
62663940000,
62679664800,
39600,
0,
'SAKT'
    ],
    [
62679625200,
62695350000,
62679668400,
62695393200,
43200,
1,
'SAKST'
    ],
    [
62695350000,
62711074800,
62695389600,
62711114400,
39600,
0,
'SAKT'
    ],
    [
62711074800,
62726799600,
62711118000,
62726842800,
43200,
1,
'SAKST'
    ],
    [
62726799600,
62742524400,
62726839200,
62742564000,
39600,
0,
'SAKT'
    ],
    [
62742524400,
62758249200,
62742567600,
62758292400,
43200,
1,
'SAKST'
    ],
    [
62758249200,
62773974000,
62758288800,
62774013600,
39600,
0,
'SAKT'
    ],
    [
62773974000,
62790303600,
62774017200,
62790346800,
43200,
1,
'SAKST'
    ],
    [
62790303600,
62806028400,
62790343200,
62806068000,
39600,
0,
'SAKT'
    ],
    [
62806028400,
62821756800,
62806068000,
62821796400,
39600,
1,
'SAKST'
    ],
    [
62821756800,
62831433600,
62821792800,
62831469600,
36000,
0,
'SAKT'
    ],
    [
62831433600,
62837467200,
62831473200,
62837506800,
39600,
0,
'SAKT'
    ],
    [
62837467200,
62853188400,
62837510400,
62853231600,
43200,
1,
'SAKST'
    ],
    [
62853188400,
62868927600,
62853228000,
62868967200,
39600,
0,
'SAKT'
    ],
    [
62868927600,
62884652400,
62868970800,
62884695600,
43200,
1,
'SAKST'
    ],
    [
62884652400,
62900377200,
62884692000,
62900416800,
39600,
0,
'SAKT'
    ],
    [
62900377200,
62916102000,
62900420400,
62916145200,
43200,
1,
'SAKST'
    ],
    [
62916102000,
62931826800,
62916141600,
62931866400,
39600,
0,
'SAKT'
    ],
    [
62931826800,
62947551600,
62931870000,
62947594800,
43200,
1,
'SAKST'
    ],
    [
62947551600,
62963881200,
62947591200,
62963920800,
39600,
0,
'SAKT'
    ],
    [
62963881200,
62982025200,
62963924400,
62982068400,
43200,
1,
'SAKST'
    ],
    [
62982025200,
62995330800,
62982064800,
62995370400,
39600,
0,
'SAKT'
    ],
    [
62995330800,
63013478400,
62995370400,
63013518000,
39600,
1,
'SAKST'
    ],
    [
63013478400,
63026784000,
63013514400,
63026820000,
36000,
0,
'SAKT'
    ],
    [
63026784000,
63044928000,
63026823600,
63044967600,
39600,
1,
'SAKST'
    ],
    [
63044928000,
63058233600,
63044964000,
63058269600,
36000,
0,
'SAKT'
    ],
    [
63058233600,
63076982400,
63058273200,
63077022000,
39600,
1,
'SAKST'
    ],
    [
63076982400,
63089683200,
63077018400,
63089719200,
36000,
0,
'SAKT'
    ],
    [
63089683200,
63108432000,
63089722800,
63108471600,
39600,
1,
'SAKST'
    ],
    [
63108432000,
63121132800,
63108468000,
63121168800,
36000,
0,
'SAKT'
    ],
    [
63121132800,
63139881600,
63121172400,
63139921200,
39600,
1,
'SAKST'
    ],
    [
63139881600,
63153187200,
63139917600,
63153223200,
36000,
0,
'SAKT'
    ],
    [
63153187200,
63171331200,
63153226800,
63171370800,
39600,
1,
'SAKST'
    ],
    [
63171331200,
63184636800,
63171367200,
63184672800,
36000,
0,
'SAKT'
    ],
    [
63184636800,
63202780800,
63184676400,
63202820400,
39600,
1,
'SAKST'
    ],
    [
63202780800,
63216086400,
63202816800,
63216122400,
36000,
0,
'SAKT'
    ],
    [
63216086400,
63234835200,
63216126000,
63234874800,
39600,
1,
'SAKST'
    ],
    [
63234835200,
63247536000,
63234871200,
63247572000,
36000,
0,
'SAKT'
    ],
    [
63247536000,
63266284800,
63247575600,
63266324400,
39600,
1,
'SAKST'
    ],
    [
63266284800,
63278985600,
63266320800,
63279021600,
36000,
0,
'SAKT'
    ],
    [
63278985600,
63297734400,
63279025200,
63297774000,
39600,
1,
'SAKST'
    ],
    [
63297734400,
63310435200,
63297770400,
63310471200,
36000,
0,
'SAKT'
    ],
    [
63310435200,
63329184000,
63310474800,
63329223600,
39600,
1,
'SAKST'
    ],
    [
63329184000,
63342489600,
63329220000,
63342525600,
36000,
0,
'SAKT'
    ],
    [
63342489600,
63360633600,
63342529200,
63360673200,
39600,
1,
'SAKST'
    ],
    [
63360633600,
63373939200,
63360669600,
63373975200,
36000,
0,
'SAKT'
    ],
    [
63373939200,
63392083200,
63373978800,
63392122800,
39600,
1,
'SAKST'
    ],
    [
63392083200,
63405388800,
63392119200,
63405424800,
36000,
0,
'SAKT'
    ],
    [
63405388800,
63424137600,
63405428400,
63424177200,
39600,
1,
'SAKST'
    ],
    [
63424137600,
63436838400,
63424173600,
63436874400,
36000,
0,
'SAKT'
    ],
    [
63436838400,
DateTime::TimeZone::INFINITY,
63436878000,
DateTime::TimeZone::INFINITY,
39600,
0,
'SAKT'
    ],
];

sub olson_version { '2012e' }

sub has_dst_changes { 30 }

sub _max_year { 2022 }

sub _new_instance
{
    return shift->_init( @_, spans => $spans );
}



1;

