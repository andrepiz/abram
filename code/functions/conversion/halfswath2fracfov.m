function fracfov = halfswath2fracfov(hs_max, hs_min, Rbody, d_body2cam, fov)
% halfswath2fracfov Computes the fraction of the camera's field of view (FOV)
% covered by a specified swath on a curved body.
%
% INPUTS:
%   hs_max        - Maximum half-swath angle (radians), measured from body center
%   hs_min        - Minimum half-swath angle (radians), measured from body center
%   Rbody         - Radius of the body (e.g., planet or moon)
%   d_body2cam    - Distance from the body's center to the camera
%   fov           - Total camera field of view (radians)
%
% OUTPUT:
%   fracfov       - Fraction of the camera's FOV occupied by the swath defined
%                   between hs_min and hs_max

% Compute the apparent angle (boresight-relative) to the swath edge at hs_max
%br_max = atan(Rbody * sin(hs_max) ./ (d_body2cam - Rbody * cos(hs_max)));
br_max = atan(sin(hs_max) ./ (d_body2cam/Rbody - cos(hs_max)));   % intolerant to rounding errors

% Compute the apparent angle to the swath edge at hs_min
%br_min = atan(Rbody * sin(hs_min) ./ (d_body2cam - Rbody * cos(hs_min)));
br_min = atan(sin(hs_min) ./ (d_body2cam/Rbody - cos(hs_min)));   % intolerant to rounding errors

% Calculate the fraction of the field of view covered by the swath
fracfov = (br_max - br_min) ./ fov;

end
