function normal = rgb2normal(rgb, nbit)
% Function to convert a rgb image to a normal map.
% Input:
%   rgb - HxWx3 RGB image
% Output:
%   normal - HxWx3 matrix where each pixel contains the [nx, ny, nz] normal vector

ana = digital2analog(rgb, 1, nbit, 1);

% Scale the normal vectors from [0, 1] to [-1, 1]
normal = ana*2 - 1;


end

