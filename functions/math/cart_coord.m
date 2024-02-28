function cart_coord = cart_coord(sph_coord)
%convert spherical coordinate in cartesian coordinates
if ~(size(sph_coord,1)==3 )
    error('Input must be 3 x N')
end

r = sph_coord(1,:,:);
az = sph_coord(2,:,:);
el = sph_coord(3,:,:);

cart_coord  = [ r.*cos(el).*cos(az)
                r.*cos(el).*sin(az)
                r.*sin(el)];

end
