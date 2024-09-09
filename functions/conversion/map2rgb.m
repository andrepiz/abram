function rgb = map2rgb(map, nbit)
% Function to convert a 3D map to an RGB image. Latitude decreases with 
% increasing rows and longitude increases with
% increasing columns
% Input:
%   map [lat x lon x 3] matrix where each element contains a 3d unit vector.
% Output:
%   rgb [u x v x 3] RGB image

% Scale the normal vectors from [-1, 1] to [0, 1]
ana = (map + 1) / 2;

rgb = analog2digital(ana, 1, 1, nbit);

end

