function [pGeom] = getGeomAlbedo(id_planet, filter)
% From: Comprehensive wide-band magnitudes and albedos for the planets, with 
% applications to exo-planets and Planet Nine  Anthony Mallama a,∗, 
% Bruce Krobusek b, Hristo Pavlov c
%
%Johnson-Cousins:  Planet U B V R I RC IC  
% Mercury 0.087 0.105 0.142 0.172 0.208 0.158 0.180 
% Venus 0.348 0.658 0.689 0.708 0.584 0.658 0.640 
% Earth 0.688 0.512 0.434 0.418 0.430 0.392 0.396 
% Mars 0.060 0.088 0.170 0.288 0.330 0.250 0.285 
% Jupiter 0.358 0.443 0.538 0.495 0.321 0.513 0.389 
% Saturn 0.203 0.339 0.499 0.568 0.423 0.646 0.543 
% Uranus 0.502 0.561 0.488 0.202 0.079 0.264 0.089 
% Neptune 0.578 0.562 0.442 0.181 0.067 0.226 0.072  
%
%Sloan:  Planet u' g' r’ i’ z’  
% Mercury 0.095 0.130 0.169 0.200 0.237 
% Venus 0.326 0.664 0.712 0.708 0.630 
% Earth 0.722 0.497 0.388 0.393 0.412 
% Mars 0.061 0.111 0.245 0.298 0.325 
% Jupiter 0.377 0.509 0.575 0.456 0.348 
% Saturn 0.209 0.436 0.618 0.601 0.450 
% Uranus 0.541 0.559 0.355 0.120 0.056
% Neptune 0.564 0.533 0.307 0.101 0.048

data_johnson = [0.087 0.105 0.142 0.172 0.208 0.158 0.180 
                0.348 0.658 0.689 0.708 0.584 0.658 0.640 
                0.688 0.512 0.434 0.418 0.430 0.392 0.396 
                0.060 0.088 0.170 0.288 0.330 0.250 0.285 
                0.358 0.443 0.538 0.495 0.321 0.513 0.389 
                0.203 0.339 0.499 0.568 0.423 0.646 0.543 
                0.502 0.561 0.488 0.202 0.079 0.264 0.089 
                0.578 0.562 0.442 0.181 0.067 0.226 0.072];

data_sloan = [0.095 0.130 0.169 0.200 0.237 
              0.326 0.664 0.712 0.708 0.630 
              0.722 0.497 0.388 0.393 0.412 
              0.061 0.111 0.245 0.298 0.325 
              0.377 0.509 0.575 0.456 0.348 
              0.209 0.436 0.618 0.601 0.450 
              0.541 0.559 0.355 0.120 0.056
              0.564 0.533 0.307 0.101 0.048];

if id_planet < 1 || id_planet > 8
    error('Input planet ID as an integer between 1 and 8')
end

switch filter
    case 'U'
        pGeom = data_johnson(id_planet, 1);
    case 'B'
        pGeom = data_johnson(id_planet, 2);
    case 'V'
        pGeom = data_johnson(id_planet, 3);
    case 'R'
        pGeom = data_johnson(id_planet, 4);
    case 'I'
        pGeom = data_johnson(id_planet, 5);
    case 'u'
        pGeom = data_sloan(id_planet, 1);
    case 'g'
        pGeom = data_sloan(id_planet, 2);
    case 'r'
        pGeom = data_sloan(id_planet, 3);
    case 'i'
        pGeom = data_sloan(id_planet, 4);
    case 'z'
        pGeom = data_sloan(id_planet, 5);
    otherwise
        error('Filter not supported. Use U, B, V, R, I, Rc, Ic (Johnson-Cousins) or u, g, r, i or z (Sloan)')
end

end

