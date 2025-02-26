function r = altlonlat2ecef(alt, lon, lat)

% WGS84 Earth Constants
a = 6378.137;  % Semi-major axis in km
f = 1 / 298.257223563;  % Flattening factor
b = a * (1 - f);  % Semi-minor axis

% Compute ECEF (x, y, z)
N = a / sqrt(1 - (1 - (b/a)^2) * sin(lat)^2);
x = (N + alt) * cos(lat) * cos(lon);
y = (N + alt) * cos(lat) * sin(lon);
z = (b^2 / a^2 * N + alt) * sin(lat);
r = [x; y; z];

end