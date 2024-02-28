function sph_coord = sph_coord(x)
% compute spherical coordinates sph_coord = [Radius; Azimuth; Elevation] of a vextor or x
% if x is a matrix 3 x N, it is interpreted as a collection of N columns vector, the output shall be 3 x N
% the elevation is bounded in [-pi/2,pi/2]
% azimuth is always obunded in [-pi,pi]

if size(x,1)~=3
    error('Input must have 3 rows')
end

sz = size(x);
az = atan2(x(2,:),x(1,:));
pos_XY = sqrt(x(1,:).^2 + x(2,:).^2);
R = sqrt(pos_XY.^2 + x(3,:).^2);
el = atan2(x(3,:),pos_XY);

sph_coord = cat(1,R,az,el);
sph_coord = reshape(sph_coord,sz);
end
