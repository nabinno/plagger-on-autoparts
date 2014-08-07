package DateTime::Event::Sunrise;

use strict;
require Exporter;
use POSIX qw(floor);
use Math::Trig;
use Carp;
use DateTime;
use DateTime::Set;
use Params::Validate qw(:all);
use Set::Infinite qw(inf $inf);
use vars qw( $VERSION $RADEG $DEGRAD @ISA );
@ISA     = qw( Exporter );
$VERSION = '0.0501';
$RADEG   = ( 180 / pi );
$DEGRAD  = ( pi / 180 );
my $INV360 = ( 1.0 / 360.0 );

my $upper_limb = '1';

sub new {
    my $class = shift;

    my %args = validate(
      @_, {
          longitude => { type => SCALAR, optional => 1 },
          latitude  => { type => SCALAR, optional => 1 },
          altitude  => {
              type    => SCALAR,
              default => '-0.833',
              regex   => qr/^(0|-0.25|-0.583|-0.833|-6|-12|-15|-18)$/
          },
          iteration => { type => SCALAR, default => '0' },
      }
    );

    return bless \%args, $class;
}

sub sunrise {

    #
    #
    # FUNCTIONAL SEQUENCE for sunrise 
    #
    # _GIVEN
    # A sunrise class that was created by the new method
    #
    # _THEN
    #
    # setup subs for following/previous rise times  
    #   
    #
    # _RETURN
    #
    # A new DateTime::Set recurrence object 
    #

    my $class = shift;
    my $self  = $class->new(@_);
    return DateTime::Set->from_recurrence(
      next => sub {
          return $_[0] if $_[0]->is_infinite;
          $self->_following_sunrise( $_[0] );
      },
      previous => sub {
          return $_[0] if $_[0]->is_infinite;
          $self->_previous_sunrise( $_[0] );
      } );
}

sub sunset {

    #
    #
    # FUNCTIONAL SEQUENCE for sunset  
    # 
    # _GIVEN
    # 
    # A sunrise class that was created by the new method
    # _THEN
    #
    # Setup subs for following/previous set times
    # 
    #
    # _RETURN
    #
    # A new DateTime::Set recurrence object
    #

    my $class = shift;
    my $self  = $class->new(@_);
    return DateTime::Set->from_recurrence(
      next => sub {
          return $_[0] if $_[0]->is_infinite;
          $self->_following_sunset( $_[0] );
      },
      previous => sub {
          return $_[0] if $_[0]->is_infinite;
          $self->_previous_sunset( $_[0] );
      } );
}

sub sunset_datetime {

    #
    #
    # FUNCTIONAL SEQUENCE for sunrise_sunset 
    #
    # _GIVEN
    # 
    # A sunrise class
    # A DateTime object
    # 
    # _THEN
    #
    #  Validate the DateTime object is valid  
    #  Compute sunrise and sunset  
    #      
    #
    # _RETURN
    #
    #  DateTime object that contains the set time
    #
    my $self  = shift;
    my $dt    = shift;
    my $class = ref($dt);

    if ( $class ne 'DateTime' ) {
        croak("Dates need to be DateTime objects");
    }
    my ( undef, $tmp_set ) = _sunrise( $self, $dt );
    return $tmp_set;
}

sub sunrise_datetime {

    #
    #
    # FUNCTIONAL SEQUENCE for sunrise_sunset 
    #
    # _GIVEN
    # 
    # A sunrise class
    # A DateTime object
    # 
    # _THEN
    #
    #  Validate the DateTime object is valid  
    #  Compute sunrise and sunset  
    #      
    #
    # _RETURN
    #
    #  DateTime object that contains the rise times
    #
    my $self  = shift;
    my $dt    = shift;
    my $class = ref($dt);

    if ( $class ne 'DateTime' ) {
        croak("Dates need to be DateTime objects");
    }
    my ( $tmp_rise, undef ) = _sunrise( $self, $dt );
    return $tmp_rise;
}

sub sunrise_sunset_span {

    #
    #
    # FUNCTIONAL SEQUENCE for sunrise_sunset 
    #
    # _GIVEN
    # 
    # A sunrise class
    # A DateTime object
    # 
    # _THEN
    #
    #  Validate the DateTime object is valid  
    #  Compute sunrise and sunset  
    #      
    #
    # _RETURN
    #
    #  DateTime Span object that contains the rise/set times
    #
    my $self  = shift;
    my $dt    = shift;
    my $class = ref($dt);

    if ( $class ne 'DateTime' ) {
        croak("Dates need to be DateTime objects");
    }
    my ( $tmp_rise, $tmp_set ) = _sunrise( $self, $dt );

    return DateTime::Span->from_datetimes(
      start => $tmp_rise,
      end   => $tmp_set
    );
}

sub _following_sunrise {

    #
    #
    # FUNCTIONAL SEQUENCE for _following_sunrise 
    #
    # _GIVEN
    # 
    # A sunrise class
    # A DateTime object
    # 
    # _THEN
    #
    #  Validate the DateTime object is valid  
    #  Compute sunrise and return if it is greater 
    #  that the orginal if not add one day and recompute
    #      
    #
    # _RETURN
    #
    #  A new DateTime object that contains the rise time
    #

    my $self = shift;
    my $dt   = shift;
    croak( "Dates need to be DateTime objects (" . ref($dt) . ")" )
      unless ( $dt->isa('DateTime') );
    my ( $tmp_rise, undef ) = _sunrise( $self, $dt );
    return $tmp_rise if $tmp_rise > $dt;
    my $d = DateTime::Duration->new(
      days => 1,
    );
    my $new_dt = $dt + $d;
    ( $tmp_rise, undef ) = _sunrise( $self, $new_dt );
    return $tmp_rise;
}

sub _previous_sunrise {

    #
    #
    # FUNCTIONAL SEQUENCE for _previous_sunrise 
    #
    # _GIVEN
    # A sunrise class
    # A DateTime object
    #
    # _THEN
    #
    # Validate the DateTime Object
    # Compute sunrise and return if it is less than
    # the orginal object if not subtract one day and recompute
    #
    # _RETURN
    #
    # A new DateTime Object that contains the rise time 
    #

    my $self = shift;
    my $dt   = shift;
    croak( "Dates need to be DateTime objects (" . ref($dt) . ")" )
      unless ( $dt->isa('DateTime') );
    my ( $tmp_rise, undef ) = _sunrise( $self, $dt );
    return $tmp_rise if $tmp_rise < $dt;
    my $d = DateTime::Duration->new(
      days => 1,
    );
    my $new_dt = $dt - $d;
    ( $tmp_rise, undef ) = _sunrise( $self, $new_dt );
    return $tmp_rise;
}

sub _following_sunset {

    #
    #
    # FUNCTIONAL SEQUENCE for _following_sunset  
    #
    # _GIVEN
    # A sunrise class
    # A DateTime object
    #
    # _THEN
    #
    #  Validate the DateTime object is valid  
    #  Compute sunset and return if it is greater 
    #  that the orginal if not add one day and recompute
    #
    # _RETURN
    #
    #  A DateTime object with set time
    #

    my $self = shift;
    my $dt   = shift;
    croak( "Dates need to be DateTime objects (" . ref($dt) . ")" )
      unless ( ref($dt) eq 'DateTime' );
    my ( undef, $tmp_set ) = _sunrise( $self, $dt );
    return $tmp_set if $tmp_set > $dt;
    my $d = DateTime::Duration->new(
      days => 1,
    );
    my $new_dt = $dt + $d;
    ( undef, $tmp_set ) = _sunrise( $self, $new_dt );
    return $tmp_set;
}

sub _previous_sunset {

    #
    #
    # FUNCTIONAL SEQUENCE for _previous_sunset 
    #
    # _GIVEN
    #  A sunrise class
    #  A DateTime object
    #
    # _THEN
    #
    # Validate the DateTime Object
    # Compute sunset and return if it is less than
    # the orginal object if not subtract one day and recompute
    #  
    # _RETURN
    #
    # A DateTime object with set time 
    #

    my $self = shift;
    my $dt   = shift;
    croak( "Dates need to be DateTime objects (" . ref($dt) . ")" )
      unless ( $dt->isa('DateTime') );
    my ( undef, $tmp_set ) = _sunrise( $self, $dt );
    return $tmp_set if $tmp_set < $dt;
    my $d = DateTime::Duration->new(
      days => 1,
    );
    my $new_dt = $dt - $d;
    ( undef, $tmp_set ) = _sunrise( $self, $new_dt );
    return $tmp_set;
}

sub _sunrise {

    #
    #
    # FUNCTIONAL SEQUENCE for _sunrise 
    #
    # _GIVEN
    #  A sunrise class DateTime object and a DateTime object
    #
    # _THEN
    #
    # Check if iteration is set to one if so
    # initially compute sunrise/sunset (using division
    # by 15.04107 instead of 15.0) then recompute rise/set time
    # using exact moment last computed. IF iteration is set
    # to zero devide by 15.0 (only once)
    # 
    # Bug in this sub, I was blindly setting the hour and min without
    # checking if it was neg. a neg. value for hours/min is not correct
    # I changed the routine to use a duration then add the duration.
    #
    # _RETURN
    # 
    # two DateTime objects the date and time for sunrise and sunset
    #

    my $self      = shift;
    my $dt        = shift;
    my $cloned_dt = $dt->clone;
    my $altit     = $self->{altitude};
    my $iteration = defined( $self->{iteration} ) ? $self->{iteration} : 0;
    $cloned_dt->set_time_zone('floating');

    if ($iteration) {

        # This is the initial start

        my $d =
          days_since_2000_Jan_0($cloned_dt) + 0.5 - $self->{longitude} / 360.0;
        my ( $tmp_rise_1, $tmp_set_1 ) =
          _sunrise_sunset( $d, $self->{longitude}, $self->{latitude}, $altit,
          15.04107 );

# Now we have the initial rise/set times next recompute d using the exact moment
        # recompute sunrise

        my $tmp_rise_2 = 9;
        my $tmp_rise_3 = 0;
        until ( equal( $tmp_rise_2, $tmp_rise_3, 8 ) ) {

            my $d_sunrise_1 = $d + $tmp_rise_1 / 24.0;
            ( $tmp_rise_2, undef ) =
              _sunrise_sunset( $d_sunrise_1, $self->{longitude},
              $self->{latitude}, $altit, 15.04107 );
            $tmp_rise_1 = $tmp_rise_3;
            my $d_sunrise_2 = $d + $tmp_rise_2 / 24.0;
            ( $tmp_rise_3, undef ) =
              _sunrise_sunset( $d_sunrise_2, $self->{longitude},
              $self->{latitude}, $altit, 15.04107 );

        }

        my $tmp_set_2 = 9;
        my $tmp_set_3 = 0;

        until ( equal( $tmp_set_2, $tmp_set_3, 8 ) ) {

            my $d_sunset_1 = $d + $tmp_set_1 / 24.0;
            ( undef, $tmp_set_2 ) =
              _sunrise_sunset( $d_sunset_1, $self->{longitude},
              $self->{latitude}, $altit, 15.04107 );
            $tmp_set_1 = $tmp_set_3;
            my $d_sunset_2 = $d + $tmp_set_2 / 24.0;
            ( undef, $tmp_set_3 ) =
              _sunrise_sunset( $d_sunset_2, $self->{longitude},
              $self->{latitude}, $altit, 15.04107 );

        }

        my ( $second_rise, $second_set ) =
          convert_hour( $tmp_rise_3, $tmp_set_3 );

        # This is to fix the datetime object to use a duration
        # instead of blindly setting the hour/min
        my $rise_dur = DateTime::Duration->new( seconds => $second_rise );
        my $set_dur  = DateTime::Duration->new( seconds => $second_set );

        my $tmp_dt1 = DateTime->new(
          year      => $dt->year,
          month     => $dt->month,
          day       => $dt->day,
          hour      => 0,
          minute    => 0,
          time_zone => 'UTC'
        );

        my $rise_time = $tmp_dt1 + $rise_dur;
        my $set_time  = $tmp_dt1 + $set_dur;
        my $tz        = $dt->time_zone;
        $rise_time->set_time_zone($tz) unless $tz->is_floating;
        $set_time->set_time_zone($tz) unless $tz->is_floating;
        return ( $rise_time, $set_time );
    }
    else {
        my $d =
          days_since_2000_Jan_0($cloned_dt) + 0.5 - $self->{longitude} / 360.0;
        my ( $h1, $h2 ) =
          _sunrise_sunset( $d, $self->{longitude}, $self->{latitude}, $altit,
          15.0 );
        my ( $seconds_rise, $seconds_set ) = convert_hour( $h1, $h2 );
        my $rise_dur = DateTime::Duration->new( seconds => $seconds_rise );
        my $set_dur  = DateTime::Duration->new( seconds => $seconds_set );
        my $tmp_dt1  = DateTime->new(
          year      => $dt->year,
          month     => $dt->month,
          day       => $dt->day,
          hour      => 0,
          minute    => 0,
          time_zone => 'UTC'
        );

        my $rise_time = $tmp_dt1 + $rise_dur;
        my $set_time  = $tmp_dt1 + $set_dur;
        my $tz        = $dt->time_zone;
        $rise_time->set_time_zone($tz) unless $tz->is_floating;
        $set_time->set_time_zone($tz) unless $tz->is_floating;
        return ( $rise_time, $set_time );
    }

}

sub _sunrise_sunset {

    #
    #
    # FUNCTIONAL SEQUENCE for sunrise_sunset 
    #
    # _GIVEN
    # 
    #  days since jan 1 2000, longitude, latitude, $altit and $h
    # _THEN
    #
    #  Compute the sunrise/sunset times for that day   
    #      
    # _RETURN
    #
    #  rise and set times as hours (GMT Time) 
    #

    my ( $d, $lon, $lat, $altit, $h ) = @_;

    my $sidtime = revolution( GMST0($d) + 180.0 + $lon );

    my ( $sRA, $sdec ) = sun_RA_dec($d);
    my $tsouth  = 12.0 - rev180( $sidtime - $sRA ) / $h;
    my $sradius = 0.2666 / $sRA;

    if ($upper_limb) {
        $altit -= $sradius;
    }

    # Compute the diurnal arc that the Sun traverses to reach 
    # the specified altitude altit: 

    my $cost =
      ( sind($altit) - sind($lat) * sind($sdec) ) /
      ( cosd($lat) * cosd($sdec) );

    my $t;
    if ( $cost >= 1.0 ) {
        carp "Sun never rises!!\n";
        $t = 0.0;    # Sun always below altit
    }
    elsif ( $cost <= -1.0 ) {
        carp "Sun never sets!!\n";
        $t = 12.0;    # Sun always above altit
    }
    else {
        $t = acosd($cost) / 15.0;    # The diurnal arc, hours
    }

    # Store rise and set times - in hours UT 

    my $hour_rise_ut = $tsouth - $t;
    my $hour_set_ut  = $tsouth + $t;
    return ( $hour_rise_ut, $hour_set_ut );

}

sub GMST0 {

    #
    #
    # FUNCTIONAL SEQUENCE for GMST0 
    #
    # _GIVEN
    # Day number
    #
    # _THEN
    #
    # computes GMST0, the Greenwich Mean Sidereal Time  
    # at 0h UT (i.e. the sidereal time at the Greenwhich meridian at  
    # 0h UT).  GMST is then the sidereal time at Greenwich at any     
    # time of the day..
    # 
    #
    # _RETURN
    #
    # Sidtime
    #
    my ($d) = @_;

    my $sidtim0 =
      revolution( ( 180.0 + 356.0470 + 282.9404 ) +
      ( 0.9856002585 + 4.70935E-5 ) * $d );
    return $sidtim0;

}

sub sunpos {

    #
    #
    # FUNCTIONAL SEQUENCE for sunpos
    #
    # _GIVEN
    #  day number
    #
    # _THEN
    #
    # Computes the Sun's ecliptic longitude and distance */
    # at an instant given in d, number of days since     */
    # 2000 Jan 0.0. 
    # 
    #
    # _RETURN
    #
    # ecliptic longitude and distance
    # ie. $True_solar_longitude, $Solar_distance
    #
    my ($d) = @_;

    #                       Mean anomaly of the Sun 
    #                       Mean longitude of perihelion 
    #                         Note: Sun's mean longitude = M + w 
    #                       Eccentricity of Earth's orbit 
    #                       Eccentric anomaly 
    #                       x, y coordinates in orbit 
    #                       True anomaly 

    # Compute mean elements 
    my $Mean_anomaly_of_sun = revolution( 356.0470 + 0.9856002585 * $d );
    my $Mean_longitude_of_perihelion = 282.9404 + 4.70935E-5 * $d;
    my $Eccentricity_of_Earth_orbit  = 0.016709 - 1.151E-9 * $d;

    # Compute true longitude and radius vector 
    my $Eccentric_anomaly =
      $Mean_anomaly_of_sun + $Eccentricity_of_Earth_orbit * $RADEG *
      sind($Mean_anomaly_of_sun) *
      ( 1.0 + $Eccentricity_of_Earth_orbit * cosd($Mean_anomaly_of_sun) );

    my $x = cosd($Eccentric_anomaly) - $Eccentricity_of_Earth_orbit;

    my $y =
      sqrt( 1.0 - $Eccentricity_of_Earth_orbit * $Eccentricity_of_Earth_orbit )
      * sind($Eccentric_anomaly);

    my $Solar_distance = sqrt( $x * $x + $y * $y );    # Solar distance
    my $True_anomaly = atan2d( $y, $x );               # True anomaly

    my $True_solar_longitude =
      $True_anomaly + $Mean_longitude_of_perihelion;    # True solar longitude

    if ( $True_solar_longitude >= 360.0 ) {
        $True_solar_longitude -= 360.0;    # Make it 0..360 degrees
    }

    return ( $Solar_distance, $True_solar_longitude );
}

sub sun_RA_dec {

    #
    #
    # FUNCTIONAL SEQUENCE for sun_RA_dec 
    #
    # _GIVEN
    # day number, $r and $lon (from sunpos) 
    #
    # _THEN
    #
    # compute RA and dec
    # 
    #
    # _RETURN
    #
    # Sun's Right Ascension (RA) and Declination (dec)
    # 
    #
    my ($d) = @_;

    # Compute Sun's ecliptical coordinates 
    my ( $r, $lon ) = sunpos($d);

    # Compute ecliptic rectangular coordinates (z=0) 
    my $x = $r * cosd($lon);
    my $y = $r * sind($lon);

    # Compute obliquity of ecliptic (inclination of Earth's axis) 
    my $obl_ecl = 23.4393 - 3.563E-7 * $d;

    # Convert to equatorial rectangular coordinates - x is unchanged 
    my $z = $y * sind($obl_ecl);
    $y = $y * cosd($obl_ecl);

    # Convert to spherical coordinates 
    my $RA  = atan2d( $y, $x );
    my $dec = atan2d( $z, sqrt( $x * $x + $y * $y ) );

    return ( $RA, $dec );

}    # sun_RA_dec

sub days_since_2000_Jan_0 {

    #
    #
    # FUNCTIONAL SEQUENCE for days_since_2000_Jan_0 
    #
    # _GIVEN
    # A Datetime object
    #
    # _THEN
    #
    # process the DateTime object for number of days
    # since Jan,1 2000  (counted in days)
    # Day 0.0 is at Jan 1 2000 0.0 UT
    # Note that ALL divisions here should be INTEGER divisions
    #
    # _RETURN
    #
    # day number
    #

    my ($dt) = @_;

    my $base_date = DateTime->new(
      year      => 2000,
      month     => 1,
      day       => 1,
      time_zone => 'UTC',
    );

    return int( $dt->jd - $base_date->jd );
}

sub sind {
    sin( ( $_[0] ) * $DEGRAD );
}

sub cosd {
    cos( ( $_[0] ) * $DEGRAD );
}

sub tand {
    tan( ( $_[0] ) * $DEGRAD );
}

sub atand {
    ( $RADEG * atan( $_[0] ) );
}

sub asind {
    ( $RADEG * asin( $_[0] ) );
}

sub acosd {
    ( $RADEG * acos( $_[0] ) );
}

sub atan2d {
    ( $RADEG * atan2( $_[0], $_[1] ) );
}

sub revolution {

    #
    #
    # FUNCTIONAL SEQUENCE for revolution
    #
    # _GIVEN
    # any angle
    #
    # _THEN
    #
    # reduces any angle to within the first revolution 
    # by subtracting or adding even multiples of 360.0
    # 
    #
    # _RETURN
    #
    # the value of the input is >= 0.0 and < 360.0
    #

    my $x = $_[0];
    return ( $x - 360.0 * floor( $x * $INV360 ) );
}

sub rev180 {

    #
    #
    # FUNCTIONAL SEQUENCE for rev180
    #
    # _GIVEN
    # 
    # any angle
    #
    # _THEN
    #
    # Reduce input to within +180..+180 degrees
    # 
    #
    # _RETURN
    #
    # angle that was reduced
    #
    my ($x) = @_;

    return ( $x - 360.0 * floor( $x * $INV360 + 0.5 ) );
}

sub equal {

    #
    #
    # FUNCTIONAL SEQUENCE for equal
    #
    # _GIVEN
    # 
    # Two floating point numbers and Accuracy
    #
    # _THEN
    #
    # Use sprintf to format the numbers to Accuracy
    # number of decimal places
    #
    # _RETURN
    #
    # True if the numbers are equal 
    #
    my ( $A, $B, $dp ) = @_;

    return sprintf( "%.${dp}g", $A ) eq sprintf( "%.${dp}g", $B );
}

sub convert_hour {

    #
    #
    # FUNCTIONAL SEQUENCE for convert_hour 
    #
    # _GIVEN
    # Hour_rise, Hour_set 
    # hours are in UT
    #
    # _THEN
    #
    # split out the hours and minites
    # Oct 20 2003
    # will convert hours to seconds and return this
    # let DateTime handle the conversion
    #
    # _RETURN
    #
    # number of seconds

    my ( $hour_rise_ut, $hour_set_ut ) = @_;
    my $seconds_rise = floor( $hour_rise_ut * 60 * 60 );
    my $seconds_set  = floor( $hour_set_ut * 60 * 60 );

    return ( $seconds_rise, $seconds_set );
}

=head1 NAME

DateTime::Event::Sunrise - Perl DateTime extension for computing the sunrise/sunset on a given day

=head1 SYNOPSIS

 use DateTime;
 use DateTime::Event::Sunrise;
 
 my $dt = DateTime->new( year   => 2000,
                         month  => 6,
                         day    => 20,
                  );

 my $sunrise = DateTime::Event::Sunrise ->sunrise (
	                longitude =>'-118',
	                latitude =>'33',
	                altitude => '-0.833',
	                iteration => '1'
		  );

 my $sunset = DateTime::Event::Sunrise ->sunset (
	                longitude =>'-118',
	                latitude =>'33',
	                altitude => '-0.833',
	                iteration => '1'
		  );

 my $tmp_rise = $sunrise->next( $dt ); 
 
 my $dt2 = DateTime->new( year   => 2000,
                         month  => 12,
                         day    => 31,
                   );
 
 # iterator
 my $dt_span = DateTime::Span->new( start =>$dt1, end=>$dt2 );
 my $set = $sunrise->intersection($dt_span);
 my $iter = $set->iterator;
 while ( my $dt = $iter->next ) {
     print ' ',$dt->datetime;
 }

 # is it day or night?
 my $day_set = DateTime::SpanSet->from_sets( 
     start_set => $sunrise, end_set => $sunset );
 print $day_set->contains( $dt ) ? 'day' : 'night';


my $dt = DateTime->new( year   => 2000,
		 month  => 6,
		 day    => 20,
                 time_zone => 'America/Los_Angeles',
                  );

my $sunrise = DateTime::Event::Sunrise ->new(
                     longitude =>'-118' ,
		     latitude => '33',
		     altitude => '-0.833',
	             iteration => '1'
                     
);

my $tmp = $sunrise->sunrise_sunset_span($dt);
print "Sunrise is:" , $tmp->start->datetime , "\n";
print "Sunset is:" , $tmp->end->datetime;

my $dt1 = $sunrise->sunrise_datetime( $dt );
print "Sunrise is:" , $dt1->datetime  , "\n";
my $dt2 = $sunrise->sunset_datetime( $dt );
print "Sunset is:" ,  $dt2->datetime , "\n";


=head1 DESCRIPTION

This module will return a DateTime recurrence set for sunrise or sunset.

=head1 METHODS

=head2 sunrise, sunset, sunrise_sunset_span, sunrise_datetime, sunset_datetime

 my $sunrise = DateTime::Event::Sunrise ->sunrise (
                        longitude => '-118',
	                latitude =>  '33',
	                altitude =>  '-0.833',
	                iteration => '1'
		   );

 my $sunset = DateTime::Event::Sunrise ->sunset (
                        longitude => '-118',
	                latitude =>  '33',
	                altitude =>  '-0.833',
	                iteration => '1'
		   );
 my $sunrise_span = DateTime::Event::Sunrise ->new (
	                longitude => '-118',
	                latitude =>  '33',
	                altitude =>  '-0.833',
	                iteration => '1'
		   );
 my $both_times = $sunrise_span->sunrise_sunset_span($dt);
 print "Sunrise is:" , $both_times->start->datetime;
 print "Sunset is:" , $both_times->end->datetime;

 my $dt1 = $sunrise->sunrise_datetime( $dt );
 print "Sunrise is:" , $dt1->datetime  , "\n";
 my $dt2 = $sunrise->sunset_datetime( $dt );
 print "Sunset is:" ,  $dt2->datetime , "\n";


=over 4

 Eastern longitude is entered as a positive number
 Western longitude is entered as a negative number
 Northern latitude is entered as a positive number
 Southern latitude is entered as a negative number

=back

Iteration is set to either 0 or 1.
If set to 0 no Iteration will occur.
If set to 1 Iteration will occur.
Default is 0.

There are a number of sun altitudes to chose from. The default is
-0.833 because this is what most countries use. Feel free to
specify it if you need to. Here is the list of values to specify
altitude (Altitude) with:

=over 4

=item * B<0> degrees

Center of Sun's disk touches a mathematical horizon

=item * B<-0.25> degrees

Sun's upper limb touches a mathematical horizon

=item * B<-0.583> degrees

Center of Sun's disk touches the horizon; atmospheric refraction accounted for

=item * B<-0.833> degrees

Sun's supper limb touches the horizon; atmospheric refraction accounted for

=item * B<-6> degrees

Civil twilight (one can no longer read outside without artificial illumination)

=item * B<-12> degrees

Nautical twilight (navigation using a sea horizon no longer possible)

=item * B<-15> degrees

Amateur astronomical twilight (the sky is dark enough for most astronomical observations)

=item * B<-18> degrees

Astronomical twilight (the sky is completely dark)

=back

=head3 Notes on Iteration

The original method only gives an approximate value of the Sun's rise/set times. 
The error rarely exceeds one or two minutes, but at high latitudes, when the Midnight Sun 
soon will start or just has ended, the errors may be much larger. If you want higher accuracy, 
you must then use the iteration feature. This feature is new as of version 0.7. Here is
what I have tried to accomplish with this.


=over 4

=item a)

Compute sunrise or sunset as always, with one exception: to convert LHA from degrees to hours,
divide by 15.04107 instead of 15.0 (this accounts for the difference between the solar day 
and the sidereal day.

=item b)

Re-do the computation but compute the Sun's RA and Decl, and also GMST0, for the moment 
of sunrise or sunset last computed.

=item c)

Iterate b) until the computed sunrise or sunset no longer changes significantly. 
Usually 2 iterations are enough, in rare cases 3 or 4 iterations may be needed.

=back

=head2 next current previous contains as_list iterator

See DateTime::Set.

=head2 ($sunrise, $sunset) = $sunrise_object->($dt);

Internal method.

Returns two DateTime objects sunrise and sunset.
Please note that the time zone for these objects
is set to UTC. So don't forget to set your timezone!!

=head1 AUTHOR

Ron Hill
rkhill@firstlight.net

=head1 SPECIAL THANKS

=over 4

=item Robert Creager [Astro-Sunrise@LogicalChaos.org]

for providing help with converting Paul's C code to perl.

=item Flavio S. Glock [fglock@pucrs.br]

for providing the the interface to the DateTime::Set
module.

=back

=head1 CREDITS

=over 4

=item Paul Schlyer, Stockholm, Sweden 

for his excellent web page on the subject.

=item Rich Bowen (rbowen@rbowen.com)

for suggestions.

=back

=head1 COPYRIGHT and LICENSE

Here is the copyright information provided by Paul Schlyer:

Written as DAYLEN.C, 1989-08-16

Modified to SUNRISET.C, 1992-12-01

(c) Paul Schlyter, 1989, 1992

Released to the public domain by Paul Schlyter, December 1992

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHOR BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

=head1 SEE ALSO

perl(1).

DateTime Web page at http://datetime.perl.org/

DateTime::Set documentation

DateTime::SpanSet documentation

=cut
1;

