function [ap_mag, ap_mag_distance, ap_mag_phase] = computeMag(planet, d_planet2sun, d_planet2earth, phase_angle, lonlat_sun_planetoc, lonlat_earth_planetoc, lon_helioc, year, flag_rings, flag_limit)
%Compute the apparent magnitude for each of the planets of the solar system
%from analytical phase laws based on observations from Earth
% Reference: 'Computing Apparent Planetary Magnitude for the Astronomical Almanac'

if ~exist('flag_limit','var')
    flag_limit = true;
end
if ~exist('flag_rings','var')
    flag_rings = false;
end
if ~exist('year','var')
    year = 2025;
end

AU = 149597870700;
lon_sun_planetoc = wrapTo2Pi(lonlat_sun_planetoc(1,:));
lon_earth_planetoc = wrapTo2Pi(lonlat_earth_planetoc(1,:));
lat_sun_planetoc = lonlat_sun_planetoc(2,:);
lat_earth_planetoc = lonlat_earth_planetoc(2,:);

switch planet

    case 'mercury'
        [ap_mag, ap_mag_distance, ap_mag_phase] = mercuryMag(d_planet2sun/AU, d_planet2earth/AU, rad2deg(abs(phase_angle)), flag_limit);

    case 'venus'
        [ap_mag, ap_mag_distance, ap_mag_phase] = venusMag(d_planet2sun/AU, d_planet2earth/AU, rad2deg(abs(phase_angle)), flag_limit);

    case 'earth'
        [ap_mag, ap_mag_distance, ap_mag_phase] = earthMag(d_planet2sun/AU, d_planet2earth/AU, rad2deg(abs(phase_angle)), flag_limit);

    case 'mars'
        [ap_mag, ap_mag_distance, ap_mag_phase] = marsMag(d_planet2sun/AU, d_planet2earth/AU, rad2deg(abs(phase_angle)), rad2deg(lon_sun_planetoc), rad2deg(lon_earth_planetoc), rad2deg(lon_helioc), flag_limit);

    case 'jupiter'
        [ap_mag, ap_mag_distance, ap_mag_phase] = jupiterMag(d_planet2sun/AU, d_planet2earth/AU, rad2deg(abs(phase_angle)), flag_limit);

    case 'saturn'
        [ap_mag, ap_mag_distance, ap_mag_phase] = saturnMag(d_planet2sun/AU, d_planet2earth/AU, rad2deg(abs(phase_angle)), rad2deg(lat_sun_planetoc), rad2deg(lat_earth_planetoc), flag_rings, flag_limit);

    case 'uranus'
        [ap_mag, ap_mag_distance, ap_mag_phase] = uranusMag(d_planet2sun/AU, d_planet2earth/AU, rad2deg(abs(phase_angle)), rad2deg(lat_sun_planetoc), rad2deg(lat_earth_planetoc), flag_limit);

    case 'neptune'
        [ap_mag, ap_mag_distance, ap_mag_phase] = neptuneMag(d_planet2sun/AU, d_planet2earth/AU, rad2deg(abs(phase_angle)), year, flag_limit);

    otherwise
        error('Planet not supported!')

end

end

function [ap_mag, ap_mag_distance, ap_mag_phase] = earthMag(r, delta, ph_ang, flag_limit)
%Compute apparent magnitudes of the Earth
%
% --INPUTS
% double precision      r           %distance from Sun (AU)
% double precision      delta       %distance from Earth (AU)
% double precision      ph_ang      %phase angle (degrees)
% --OUTPUTS
% double precision      ap_mag      %apparent magnitude (Mallama et al. 2017 and later)

%Parameter
phase_angle_upper_limit = 170.0; %upper limit of the phase angles for which magnitudes are thought to be realistic
  
%Calculate the apparent magnitude
ap_mag_distance = distanceMag(r, delta);

%Compute the phase angle factor
ap_mag_phase = -3.99 -1.060e-03 * ph_ang + 2.054e-04 * ph_ang.^2;
if flag_limit 
    ap_mag_phase(ph_ang > phase_angle_upper_limit) = nan; 
end

%Add factors to determine the apparent magnitude
ap_mag = ap_mag_distance + ap_mag_phase;
  
end


function [ap_mag, ap_mag_distance, ap_mag_phase] = jupiterMag(r, delta, ph_ang, flag_limit)
%Compute apparent magnitudes of Jupiter
%
% --INPUTS
% double precision      r           %distance from Sun (AU)
% double precision      delta       %distance from Earth (AU)
% double precision      ph_ang      %phase angle (degrees)
% --OUTPUTS
% double precision      ap_mag      %apparent magnitude (Mallama et al. 2017 and later)

%Parameters
geocentric_phase_angle_limit = 12.0; %Phase angle limit for using equations #8 and #9
phase_angle_upper_limit = 130.0; %upper limit of the observed range of phase angles

%Calculate the apparent magnitude
ap_mag_distance = distanceMag(r, delta);

%Use equation #9 for phase angles above the geocentric limit
ap_mag_phase = -9.428 -2.5 * log10( 1.0 - 1.507 * (ph_ang / 180.)    - 0.363 * ...
                (ph_ang / 180.).^2 - 0.062 * (ph_ang / 180.).^3 ...
                + 2.809 * (ph_ang / 180.).^4 - 1.876 * (ph_ang / 180.).^5 );
%Use equation #8 for phase angles below the geocentric limit
ixs_case_1 = ( ph_ang <= geocentric_phase_angle_limit );
ap_mag_phase(ixs_case_1) = -9.395 -3.7E-04 * ph_ang(ixs_case_1) + 6.16E-04 * ph_ang(ixs_case_1).^2;

if flag_limit 
    ap_mag_phase(ph_ang > phase_angle_upper_limit) = nan; 
end

ap_mag = ap_mag_distance + ap_mag_phase;


end

function [ap_mag, ap_mag_distance, ap_mag_phase] = marsMag(r, delta, ph_ang, lon_sun_planetoc, lon_earth_planetoc, lon_helioc, flag_limit)
%Compute apparent magnitudes of Mars
%
% --INPUTS
% double precision      r           %distance from Sun (AU)
% double precision      delta       %distance from Earth (AU)
% double precision      ph_ang      %phase angle (degrees)
% double precision      lon_earth  %Sub-Earth longitude in degrees
% double precision      lon_sun    %Sub-Sun longitude in degrees
% double precision      lon_ecl      %heliocentric ecliptic longitude
%
% --OUTPUTS
% double precision      ap_mag      %apparent magnitude (Mallama et al. 2017 and later)

%Parameter
Ls_offset = -85.0; %Add to convert from helioncentric ecliptic longitude to vernal equinox longitude (Ls)
geocentric_phase_angle_limit = 50.0; %Phase angle limit for using equations #6 and #7
phase_angle_upper_limit = 120.0; %upper limit of the phase angle for reliable magnitudes

%Calculate the apparent magnitude
ap_mag_distance = distanceMag(r, delta);

%Add factors to determine the apparent magnitude
%Use equation #7 for phase angles above the geocentric limit
ap_mag_phase = -0.367 - 0.02573 * ph_ang + 0.0003445 * ph_ang.^2;
%Use equation #6 for phase angles below the geocentric limit
ixs_case_1 = ( ph_ang <= geocentric_phase_angle_limit );
ap_mag_phase(ixs_case_1) = -1.601 + 2.267E-02 * ph_ang(ixs_case_1) - 1.302E-04 * ph_ang(ixs_case_1).^2;
if flag_limit 
    ap_mag_phase(ph_ang > phase_angle_upper_limit) = nan; 
end

%Compute the effective central meridian longitude, i.e. the average 
%of sub-Earth and sub-Sun longitudes
eff_CM = ( lon_earth_planetoc + lon_sun_planetoc ) ./ 2.;
eff_CM( abs ( lon_earth_planetoc - lon_sun_planetoc ) > 180. ) = eff_CM( abs ( lon_earth_planetoc - lon_sun_planetoc ) > 180. ) + 180.;
eff_CM( eff_CM > 360. ) = eff_CM( eff_CM > 360. ) - 360.;

%Use Stirling interpolation to determine the magnitude correction for
%rotation
ap_mag_rot = marsMagCorrStirling('R', eff_CM);
  
%Convert the ecliptic longitude to Ls, i.e. the vernal equinox longitude 
% (= 0 at vernal equinox, = 90 for north hemisphere summer)
Ls = lon_helioc + Ls_offset;
Ls( Ls > 360. )  = Ls( Ls > 360. )  - 360.;
Ls( Ls <   0. ) = Ls( Ls <   0.) + 360.;
  
%Use Stirling interpolation to determine the magnitude correction for orbit
ap_mag_orb = marsMagCorrStirling('O', Ls);

ap_mag = ap_mag_distance + ap_mag_phase + ap_mag_rot + ap_mag_orb;

end


function [ap_mag, ap_mag_distance, ap_mag_phase] = mercuryMag(r, delta, ph_ang, flag_limit)
%Compute apparent magnitudes of Mercury
%
% --INPUTS
% double precision      r           %distance from Sun (AU)
% double precision      delta       %distance from Earth (AU)
% double precision      ph_ang      %phase angle (degrees)
%
% --OUTPUTS
% double precision      ap_mag      %apparent magnitude (Mallama et al. 2017 and later)

%Parameters
phase_angle_lower_limit = 2.0; %lower limit of the observed range of phase angles
phase_angle_upper_limit = 170.0; %upper limit of the observed range of phase angles

%Calculate the apparent magnitude
ap_mag_distance = distanceMag(r, delta);
 
%Compute the phase angle factor
%ap_mag_phase =  + 6.617E-02 * ph_ang    - 1.867E-03 * ph_ang.^2  ...
%+ 4.103E-05 * ph_ang.^3 - 4.583E-07 * ph_ang.^4 ...
%+ 2.643E-09 * ph_ang.^5 - 7.012E-12 * ph_ang.^6 + 6.592E-15 * ph_ang.^7

%6th order
ap_mag_phase = -0.613 + 6.3280e-02 * ph_ang    - 1.6336e-03 * ph_ang.^2  ...
                + 3.3644e-05 * ph_ang.^3 ...
                - 3.4265e-07 * ph_ang.^4 + 1.6893e-09 * ph_ang.^5 - 3.0334e-12 * ph_ang.^6;
if flag_limit 
    ap_mag_phase(ph_ang > phase_angle_upper_limit | ph_ang < phase_angle_lower_limit) = nan; 
end

%Add factors to determine the apparent magnitude
ap_mag = ap_mag_distance + ap_mag_phase;
  
end

function [ap_mag, ap_mag_distance, ap_mag_phase] = neptuneMag(r, delta, ph_ang, year, flag_limit)
%Compute apparent magnitudes of Neptune
%16 - small phase angles
%17 - large phase angles and dates after year 2000.0
%
% --INPUTS
% double precision      r           %distance from Sun (AU)
% double precision      delta       %distance from Earth (AU)
% double precision      ph_ang      %phase angle (degrees)
% integer               year        %calendar year (years)
%
% --OUTPUTS
% double precision      ap_mag      %apparent magnitude (Mallama et al. 2017 and later)


%Parameters
geocentric_phase_angle_limit = 1.9; %Phase angle limit for using equations #6 and #7
phase_angle_upper_limit = 133.14; %upper limit of the observed range of phase angles

%Calculate the apparent magnitude
ap_mag_distance = distanceMag(r, delta);
 
%Equation 16 - compute the magnitude at unit distance as a function of time
ap_mag( year > 2000.0 ) = -7.00;
ap_mag( year < 1980.0 ) = -6.89;
ap_mag( year >= 1980 && year <= 2000.) = -6.89 - 0.0054 * ( year - 1980.0 );

%Add phase angle factor from equation 17 if needed
% effects of phase angle are on the milli-magnitude level and thus ignored
ap_mag_phase = ap_mag.*ones(1, length(ph_ang));
%Check the year because equation 17 only pertains to t > 2000.0
ixs_case_1 = (ph_ang > geocentric_phase_angle_limit &  year > 2000. );
ap_mag_phase(ixs_case_1) = ap_mag + 7.944e-3 * ph_ang(ixs_case_1) + 9.617e-5 * ph_ang(ixs_case_1).^2;
if flag_limit 
    ap_mag_phase(ph_ang > phase_angle_upper_limit) = nan; 
end

%Add factors to determine the apparent magnitude
ap_mag = ap_mag_distance + ap_mag_phase;

end

function [ap_mag, ap_mag_distance, ap_mag_phase] = saturnMag(r, delta, ph_ang, lat_sun_planetoc, lat_earth_planetoc, flag_rings, flag_limit)
%Compute apparent magnitudes of Saturn
%Equations:
%10 - globe and ring for geocentric values of phase angle and inclination
%11 - globe alone for geocentric phase angles
%12 - globe alone beyond geocentric phase angles

%
% --INPUTS
% double precision      r           %distance from Sun (AU)
% double precision      delta       %distance from Earth (AU)
% double precision      ph_ang      %phase angle (degrees)
% double precision      lat_sun,  %sub-sun geographic latitudes
% double precision      lat_earth %sub-earth geographic latitudes
% logical               rings   % true if for globe and rings, false for globe alone
%
% --OUTPUTS
% double precision      ap_mag      %apparent magnitude (Mallama et al. 2017 and later)

%Parameters
geocentric_phase_angle_limit = 6.5; %Phase angle limit for using equations #10 and #11 versus #12
lat_planetoc_max = 27.0; %Inclination angle limit for using equation #10
phase_angle_upper_limit = 150.0; %upper limit of the observed range of phase angles

%Calculate the apparent magnitude
ap_mag_distance = distanceMag(r, delta);
 
% %Compute the effective sub-latitude geocentric points
%e2 = 0.8137;  %eccentricity squared of Saturn ellipse
% lat_sun_planetoc = saturn_geodetic2geocentric( lat_sun_geod,  e2);
% lat_earth_planetoc = saturn_geodetic2geocentric( lat_earth_geod,  e2);

%Take the square root of the product of the saturnicentric latitude of
%the Sun and that of Earth but set to zero when the signs are opposite.
% this case covers a rare condition where the Sun lights one side of
% the rings and the observer sees the other side, so the rings are 
% backlit and very faint
lat_sunearth_planetoc_product = lat_sun_planetoc .* lat_earth_planetoc;
lat_sunearth_planetoc = zeros(1, length(lat_sunearth_planetoc_product));
lat_sunearth_planetoc(lat_sunearth_planetoc_product >= 0.) = sqrt ( lat_sunearth_planetoc_product(lat_sunearth_planetoc_product >= 0.) );

%Compute the effect of phase angle and inclination
ap_mag_phase = nan(1, length(ph_ang));

%Use equation #10 for globe+rings and geocentric circumstances
ixs_case_1 = (flag_rings & ph_ang <= geocentric_phase_angle_limit & lat_sunearth_planetoc <= lat_planetoc_max );
ap_mag_phase(ixs_case_1) = -8.914 - 1.825 * sind( lat_sunearth_planetoc(ixs_case_1) ) + 0.026 * ph_ang(ixs_case_1) - 0.378   ...
       * sind( lat_sunearth_planetoc(ixs_case_1) ) .* exp( -2.25 * ph_ang(ixs_case_1) );

%Use equation #11 for globe-alone and geocentric circumstances
ixs_case_2 = (~ flag_rings & ph_ang <= geocentric_phase_angle_limit &  lat_sunearth_planetoc <= lat_planetoc_max );
ap_mag_phase(ixs_case_2) = -8.95 - 3.7e-4 * ph_ang(ixs_case_2) + 6.16e-4 * ph_ang(ixs_case_2).^2;

%Use equation #12 for globe-alone beyond geocentric phase angle limit
ixs_case_3 = (~ flag_rings & ph_ang > geocentric_phase_angle_limit );
ap_mag_phase(ixs_case_3) = -8.94 + 2.446e-4 * ph_ang(ixs_case_3) + 2.672e-4 * ph_ang(ixs_case_3).^2 - 1.506e-6 *  ...
                        ph_ang(ixs_case_3).^3 +4.767e-9 * ph_ang(ixs_case_3).^4;

if flag_limit 
    ap_mag_phase(ph_ang > phase_angle_upper_limit) = nan; 
end

%Add the distance factors to determine the apparent magnitude
ap_mag = ap_mag_distance + ap_mag_phase;
end
  

function [ap_mag, ap_mag_distance, ap_mag_phase] = uranusMag(r, delta, ph_ang, lat_sun_planetoc, lat_earth_planetoc, flag_limit)
%Compute apparent magnitudes of Uranus 
%
% --INPUTS
% double precision      r           %distance from Sun (AU)
% double precision      delta       %distance from Earth (AU)
% double precision      ph_ang      %phase angle (degrees)
% double precision      lat_sun     %planetographic Sun sub-latitude
% double precision      lat_earth   %planetographic earth sub-latitude
% logical               rings   % true if for globe and rings, false for globe alone
%
% --OUTPUTS
% double precision      ap_mag      %apparent magnitude (Mallama et al. 2017 and later)

%Parameters
geocentric_phase_angle_limit = 3.1; %Phase angle limit for using equations #8 and #9
phase_angle_upper_limit = 154.0; %upper limit of the observed range of phase angles
flattening = 0.0022927;

%Calculate the apparent magnitude
ap_mag_distance = distanceMag(r, delta);
 
%Compute the effective sub-latitude point by taking the average of the 
% absolute values of the planetographic latitudes of the Sun and that of Earth
lat_sun_planetog = planetoc2planetog(lat_sun_planetoc, flattening);
lat_earth_planetog = planetoc2planetog(lat_earth_planetoc, flattening);
lat_sunearth_planetog = ( abs( lat_sun_planetog ) + abs ( lat_earth_planetog ) ) / 2.;

%Compute the sub-latitude factor
ap_mag_lat = -0.00084 * lat_sunearth_planetog;

%Compute the magnitude depending on the phase angle
ap_mag_phase = -7.110*ones(1, length(ph_ang));
ixs_case_1 = ( ph_ang > geocentric_phase_angle_limit );
%Use equation #13 for phase angles below the geocentric limit
ap_mag_phase(ixs_case_1) = -7.110 + 6.587e-3 * ph_ang(ixs_case_1) + 1.045e-4 * ph_ang(ixs_case_1).^2;
if flag_limit 
    ap_mag_phase(ph_ang > phase_angle_upper_limit) = nan; 
end

%Add the distance factors to determine the apparent magnitude
ap_mag = ap_mag_distance + ap_mag_phase + ap_mag_lat;

end


function [ap_mag, ap_mag_distance, ap_mag_phase] = venusMag(r, delta, ph_ang, flag_limit)
%Compute apparent magnitudes of Venus
%
% --INPUTS
% double precision      r           %distance from Sun (AU)
% double precision      delta       %distance from Earth (AU)
% double precision      ph_ang      %phase angle (degrees)
% double precision      lat_sun     %planetographic Sun sub-latitude
% double precision      lat_earth   %planetographic earth sub-latitude
% logical               rings   % true if for globe and rings, false for globe alone
%
% --OUTPUTS
% double precision      ap_mag      %apparent magnitude (Mallama et al. 2017 and later)

%Parameters
phase_angle_lower_limit = 2.0;                      %lower limit of the observed range of phase angles
phase_angle_upper_limit = 179.0; %upper limit of the observed range of phase angles

%Calculate the apparent magnitude
ap_mag_distance = distanceMag(r, delta);
 
%Compute the phase angle factor 
%phase angle greater than or equal to 163.7 (equation #4)
ap_mag_phase = 236.05828 - 2.81914E+00 * ph_ang + 8.39034E-03 * ph_ang.^2;
%phase angle less 163.7 degrees (equation #3)
ixs_case_1 = ( ph_ang < 163.7 );
ap_mag_phase(ixs_case_1) = -4.384 -1.044E-03 * ph_ang(ixs_case_1) + 3.687E-04 * ph_ang(ixs_case_1).^2 - 2.814E-06 *  ...
    ph_ang(ixs_case_1).^3 + 8.938E-09 * ph_ang(ixs_case_1).^4;
if flag_limit 
    ap_mag_phase(ph_ang > phase_angle_upper_limit | ph_ang < phase_angle_lower_limit) = nan; 
end

%Add factors to determine the apparent magnitude
ap_mag = ap_mag_distance + ap_mag_phase;
end
  

function [ap_mag_distance, r_mag_factor, delta_mag_factor] = distanceMag(r, delta)
% Compute the magnitude factor due to distance from earth and sun
%
% INPUTS
% double precision      r           %distance from Sun (AU)
% double precision      delta       %distance from Earth (AU)
% OUTPUTS
% double precision      r_mag_factor         %distance 'r' factor in magnitudes
% double precision      delta_mag_factor     %distance 'delta' factor in magnitudes
% double precision      ap_mag_distance  %distance (r and delta) factor in magnitudes

%Compute the 'r' distance factor
r_mag_factor = 2.5 * log10 ( r .* r );

%Compute the 'delta' distance factor
delta_mag_factor = 2.5 * log10 (delta .* delta);

%Compute the distance factor
ap_mag_distance = r_mag_factor + delta_mag_factor;

end

function planetoc = planetog2planetoc(planetog, f)
%convert planetographic to planetocentric 

% double precision          geodetic    %geodetic latitude
% double precision          f %planet flattening

%convert geodetic to geocentric
planetoc = atand( (1-f).^2 .* tand( planetog ) );

end

function planetog = planetoc2planetog(planetoc, f)
%convert planetocentric to planetographic 

% double precision          geocentric  %geocentric laitude
% double precision          f %planet flattening

planetog = atand( tand(planetoc ) / ((1-f).^2) );
  
end

function  mag_corr  = marsMagCorrStirling(ch, angle)
%Compute the magnitude correction for rotation angle or orbital position based
%on data from Mallama, 2016, Icarus, 192, 404-416
%Stirling interpolation algorithm from Duncombe in Computational Techniques in
%Explanatory Supplement to the Astronomical Almanac
%This code is based on Hilton's python code
%Example is from 'https://mat.iitm.ac.in/home/sryedida/public_html/caimna/interpolation/cdf.html'

%--INPUTS
% character*1              Ch           %'R' for rotation, 'O' for orbit, 'X' for example
% double precision         angle        %rotational or orbital angle, degrees
%
%--OUTPUTS
% double precision         mag_corr     %the resulting magnitude correction
%
%--PARAMETERS
% integer                  i, j         %loop indices
% integer                  zero_point   % mid-point in the array of 5 values from which to interpolate
% double precision         p(0:5)       %differences in angles raised to powers
% double precision         delta(0:4), delta_2(0:3), delta_3(0:2), delta_4 % differences in magnitude table entries
% double precision         a(0:4)       % polynomial coefficients
% double precision         L1(0:39)     % magnitude corrections for rotational longitue from Table 6 of Mallama 2007
% double precision         L2(0:39)     % magnitude corrections for orbit location from Table 8 of Mallama 2007
% double precision         f(0:6)       %array for the example
% logical                  L1_finished  %flag for generating L1 and L2 files for plotting

array_offset =  0; %difference between Fortran and Python

% Empirical rotational longitude function (longitude is the average of subobserver and sub-solar)
% Between -20 deg and 380 deg going west
L1 = [0.024,  0.034,  0.036,  0.045,  0.038,  0.023,  0.015,  0.011, ...
       0.000, -0.012, -0.018, -0.036, -0.044, -0.059, -0.060, -0.055, ...
      -0.043, -0.041, -0.041, -0.036, -0.036, -0.018, -0.038, -0.011, ...
       0.002,  0.004,  0.018,  0.019,  0.035,  0.050,  0.035,  0.027, ...
       0.037,  0.048,  0.025,  0.022,  0.024,  0.034,  0.036,  0.045];
% Orbital longitude function
% Between -20 deg and 380 deg going west
L2 = [-0.030, -0.017, -0.029, -0.017, -0.014, -0.006, -0.018, -0.020, ...
      -0.014, -0.030, -0.008, -0.040, -0.024, -0.037, -0.036, -0.032, ...
       0.010,  0.010, -0.001,  0.044,  0.025, -0.004, -0.016, -0.008, ...
       0.029, -0.054, -0.033,  0.055,  0.017,  0.052,  0.006,  0.087, ...
       0.006,  0.064,  0.030,  0.019, -0.030, -0.017, -0.029, -0.017];

f = [0.0,     ...
    0.0,     ...
    0.23967, ...
    0.28060, ...
    0.31788, ...
    0.35209, ...
    0.38368];

%Determine the starting point for the differences and p, an array of the 
%proportional distance of the longitude between the two tabulated values
%raised to the nth power.
zero_point = floor(angle / 10.0) + array_offset;
p(1,:) = ones(1, length(angle));
p(2,:) = angle / 10.0 - zero_point ;
for i = 3:5                      
    p(i,:) = p(2,:).^(i-1)  ;               
end

%Calcute arrays of the first through fourth differences
for i = 1:4                           %for i in range(4):
    if (ch == 'R') 
      delta(i, :) = L1(i + 1 + zero_point)- L1(i + zero_point);
    end
    if (ch == 'O') 
      delta(i, :) =  L2(i + 1 + zero_point)- L2(i + zero_point);
    end
    if (ch == 'X') 
      delta(i, :) = f (i + 1 + zero_point)- f (i + zero_point);
    end
end
for i = 1:3
  delta_2(i, :) = delta(i + 1, :) - delta(i, :);
end
for i = 1:2
  delta_3(i, :) = delta_2(i + 1, :) - delta_2(i, :);
end
delta_4 = delta_3(2, :) - delta_3(1, :);

%Convert differences into polynomial coefficients.
if (ch == 'X') 
    a(1, :) = f(3 + zero_point);
end
if (ch == 'R') 
    a(1, :) =  L1(3 + zero_point);
end
if (ch == 'O') 
    a(1, :) =  L2(3 + zero_point);
end
a(5, :) = delta_4 / 24.0;
a(4, :) = (delta_3(1) + delta_3(2)) / 12.0;
a(3, :) = delta_2(2) / 2.0 - a(5);
a(2, :) = (delta(2) + delta(3))/ 2.0 - a(4);

%Evaluate the polynomial to compute the magnitude correction
mag_corr = zeros(1, length(angle));
for i = 1:5
  mag_corr = mag_corr + a(i, :) .* p(i, :);
end
end
